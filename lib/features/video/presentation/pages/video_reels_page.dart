import '../../../../core/exports.dart';
import '../../domain/entities/video_entity.dart';
import '../bloc/video_bloc.dart';
import '../bloc/video_event.dart';
import '../bloc/video_state.dart';
import '../widgets/no_internet_widget.dart';

class VideoReelsPage extends StatefulWidget {
  const VideoReelsPage({super.key});

  @override
  State<VideoReelsPage> createState() => _VideoReelsPageState();
}

class _VideoReelsPageState extends State<VideoReelsPage> {
  final PageController _pageController = PageController();
  final Map<int, VideoPlayerController> _controllers = {};
  final Set<int> _initializedIndexes = {};
  int _currentPage = 0;
  List<VideoEntity> _videos = [];
  bool _hasInternet = true;
  bool _isReconnecting = false;
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _checkInternetAndLoad();
    _listenToConnectivity();
    _pageController.addListener(_onPageChanged);
  }

  Future<void> _checkInternetAndLoad() async {
    final networkInfo = sl<NetworkInfo>();
    final isConnected = await networkInfo.isConnected;
    if (!mounted) return;
    setState(() {
      _hasInternet = isConnected;
    });
    if (_hasInternet && mounted) {
      context.read<VideoBloc>().add(const LoadVideos());
    }
  }

  void _listenToConnectivity() {
    final networkInfo = sl<NetworkInfo>();
    _connectivitySubscription = networkInfo.onConnectivityChanged.listen((
      isConnected,
    ) {
      if (!mounted) return;

      // If internet is lost, pause all videos
      if (!isConnected) {
        _pauseAllVideos();
        setState(() {
          _hasInternet = false;
          _isReconnecting = false;
        });
      } else {
        // Internet is restored - start reconnecting
        setState(() {
          _isReconnecting = true;
        });
        _resetAndReloadVideos();
      }
    });
  }

  void _pauseAllVideos() {
    for (final controller in _controllers.values) {
      if (controller.value.isInitialized) {
        controller.pause();
      }
    }
  }

  void _resetAndReloadVideos() {
    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    _initializedIndexes.clear();

    // Reset page
    _currentPage = 0;

    // Clear videos list
    setState(() {
      _videos = [];
    });

    // Jump to first page if controller is attached
    if (_pageController.hasClients) {
      _pageController.jumpToPage(0);
    }

    // Reload videos - will set _hasInternet = true when videos are loaded
    context.read<VideoBloc>().add(const LoadVideos());
  }

  void _onPageChanged() {
    final newPage = _pageController.page?.round() ?? 0;
    if (newPage != _currentPage) {
      _handlePageChange(newPage);
    }
  }

  void _handlePageChange(int newPage) {
    // Pause current video
    _controllers[_currentPage]?.pause();

    // Play new video from start if it's a cached video
    _playVideoFromStart(newPage);

    setState(() {
      _currentPage = newPage;
    });
  }

  void _playVideoFromStart(int index) {
    final controller = _controllers[index];
    if (controller != null && controller.value.isInitialized) {
      // Seek to beginning and play
      controller.seekTo(Duration.zero);
      controller.play();
    }
  }

  Future<void> _retryInternetConnection() async {
    final networkInfo = sl<NetworkInfo>();
    final isConnected = await networkInfo.isConnected;
    if (isConnected && mounted) {
      setState(() {
        _isReconnecting = true;
      });
      _resetAndReloadVideos();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _connectivitySubscription?.cancel();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: BlocConsumer<VideoBloc, VideoState>(
        listener: (context, state) {
          if (state is VideoLoaded) {
            setState(() {
              _videos = state.videos;
              _hasInternet = true;
              _isReconnecting = false;
            });
          } else if (state is VideoLoadingMore) {
            setState(() {
              _videos = state.videos;
            });
          } else if (state is VideoError) {
            setState(() {
              _isReconnecting = false;
            });
          }
        },
        builder: (context, state) {
          // Show no internet widget if not connected
          if (!_hasInternet) {
            return NoInternetWidget(onRetry: _retryInternetConnection);
          }

          // Show loading while reconnecting or if videos are empty and loading
          if (_isReconnecting || state is VideoLoading || _videos.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.white),
            );
          }

          if (state is VideoError) {
            return _buildErrorWidget(state.message);
          }

          if (_videos.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                // Reset page and clear controllers on refresh
                _currentPage = 0;
                for (final controller in _controllers.values) {
                  controller.dispose();
                }
                _controllers.clear();
                _initializedIndexes.clear();

                // Jump to first page
                if (_pageController.hasClients) {
                  _pageController.jumpToPage(0);
                }

                context.read<VideoBloc>().add(const RefreshVideos());
              },
              color: AppColors.white,
              backgroundColor: AppColors.grey900,
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification &&
                      _pageController.hasClients &&
                      _pageController.position.pixels >=
                          _pageController.position.maxScrollExtent * 0.8) {
                    _loadMoreVideos(state);
                  }
                  return false;
                },
                child: PageView.builder(
                  controller: _pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: _videos.length + (_hasReachedMax(state) ? 0 : 1),
                  onPageChanged: (index) {
                    if (index < _videos.length) {
                      _handlePageChange(index);
                    }
                  },
                  itemBuilder: (context, index) {
                    if (index >= _videos.length) {
                      return _buildLoadingIndicator();
                    }
                    return _buildVideoItem(_videos[index], index);
                  },
                ),
              ),
            );
          }

          return Center(
            child: Text(
              Strings.noVideosAvailable,
              style: const TextStyle(color: AppColors.white),
            ),
          );
        },
      ),
    );
  }

  bool _hasReachedMax(VideoState state) {
    if (state is VideoLoaded) {
      return state.hasReachedMax;
    }
    return false;
  }

  void _loadMoreVideos(VideoState state) {
    if (state is VideoLoaded && !state.hasReachedMax) {
      context.read<VideoBloc>().add(
        LoadMoreVideos(page: state.currentPage + 1),
      );
    }
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.red,
            size: Sizes.errorIconSize,
          ),
          const SizedBox(height: Sizes.spacing16),
          Text(
            message,
            style: const TextStyle(color: AppColors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Sizes.spacing16),
          ElevatedButton(
            onPressed: () {
              context.read<VideoBloc>().add(const LoadVideos());
            },
            child: const Text(Strings.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.white),
    );
  }

  Widget _buildVideoItem(VideoEntity video, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildVideoPlayer(video, index),
        _buildGradientOverlay(),
        _buildVideoInfo(video),
        _buildPlayPauseOverlay(index),
      ],
    );
  }

  Widget _buildVideoPlayer(VideoEntity video, int index) {
    // Check if video is already cached
    final isCached = _initializedIndexes.contains(index);

    // Initialize only if:
    // 1. It's the current page, OR
    // 2. It's the previous page (for smooth backward scrolling), OR
    // 3. It's the next page (for smooth forward scrolling)
    // 4. But only if not already initialized (cached)
    final shouldInitialize =
        !isCached &&
        (index == _currentPage ||
            index == _currentPage - 1 ||
            index == _currentPage + 1);

    if (shouldInitialize) {
      _initializeController(video.videoUrl, index);
    }

    final controller = _controllers[index];

    if (controller == null || !controller.value.isInitialized) {
      return Container(
        color: AppColors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _togglePlayPause(index),
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }

  Future<void> _initializeController(String url, int index) async {
    if (_initializedIndexes.contains(index)) return;

    _initializedIndexes.add(index);
    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controllers[index] = controller;

    try {
      await controller.initialize();
      // Set video to loop when completed
      controller.setLooping(true);

      // Add listener to update UI when playing state changes
      controller.addListener(() {
        setState(() {});
      });

      // Play if this is the current page
      if (index == _currentPage) {
        controller.play();
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error initializing video: $e');
      _initializedIndexes.remove(index);
      _controllers.remove(index);
    }
  }

  void _togglePlayPause(int index) {
    final controller = _controllers[index];
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
  }

  Widget _buildGradientOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: Sizes.gradientOverlayHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppColors.black.withValues(alpha: 0.8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoInfo(VideoEntity video) {
    return Positioned(
      bottom: Sizes.videoInfoBottomPadding,
      left: Sizes.videoInfoHorizontalPadding,
      right: Sizes.videoInfoHorizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.author,
            style: TextStyle(
              color: AppColors.white,
              fontSize: Sizes.font16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Sizes.spacing8),
          Text(
            video.title,
            style: TextStyle(
              color: AppColors.white,
              fontSize: Sizes.font14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: Sizes.spacing4),
          Text(
            video.description,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.8),
              fontSize: Sizes.font12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPlayPauseOverlay(int index) {
    final controller = _controllers[index];

    // Don't show overlay while video is loading
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final isPlaying = controller.value.isPlaying;

    return GestureDetector(
      onTap: () => _togglePlayPause(index),
      child: Center(
        child: AnimatedOpacity(
          opacity: isPlaying ? 0.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(Sizes.playPauseOverlayPadding),
            child: const Icon(
              Icons.play_arrow,
              color: AppColors.white,
              size: Sizes.icon48,
            ),
          ),
        ),
      ),
    );
  }
}
