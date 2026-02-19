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
  PageController _pageController = PageController();
  final Map<int, VideoPlayerController> _controllers = {};
  int _currentPage = 0;
  List<VideoEntity> _videos = [];
  bool _hasInternet = true;
  bool _isReconnecting = false;
  StreamSubscription<bool>? _connectivitySubscription;
  UniqueKey _pageViewKey = UniqueKey();

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

      if (!isConnected) {
        // Internet is lost - pause all videos
        _pauseAllVideos();
        setState(() {
          _hasInternet = false;
          _isReconnecting = false;
        });
      } else {
        // Internet is restored
        setState(() {
          _isReconnecting = true;
        });
        _handleReconnection();
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

  void _disposeAllControllers() {
    for (final controller in _controllers.values) {
      controller.pause();
      controller.dispose();
    }
    _controllers.clear();
  }

  void _handleReconnection() {
    // Dispose all video controllers
    _disposeAllControllers();

    // Reset page
    _currentPage = 0;

    // Dispose old PageController and create new one
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);

    // Generate new key to force PageView rebuild
    _pageViewKey = UniqueKey();

    // Clear videos and reload
    setState(() {
      _videos = [];
    });

    // Reload videos from API
    context.read<VideoBloc>().add(const LoadVideos());
  }

  void _onPageChanged() {
    if (!_pageController.hasClients) return;
    final newPage = _pageController.page?.round() ?? 0;
    if (newPage != _currentPage) {
      _handlePageChange(newPage);
    }
  }

  void _handlePageChange(int newPage) {
    // Pause current video
    _controllers[_currentPage]?.pause();

    // Play new video from start
    _playVideoFromStart(newPage);

    setState(() {
      _currentPage = newPage;
    });
  }

  void _playVideoFromStart(int index) {
    final controller = _controllers[index];
    if (controller != null && controller.value.isInitialized) {
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
      _handleReconnection();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _connectivitySubscription?.cancel();
    _disposeAllControllers();
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

          // Show loading while reconnecting or initial loading
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
                _currentPage = 0;
                _disposeAllControllers();

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
                  key: _pageViewKey,
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
    final controller = _controllers[index];
    final isInitialized = controller?.value.isInitialized ?? false;

    // Initialize if controller doesn't exist and it's current, previous, or next page
    final shouldInitialize =
        controller == null &&
        (index == _currentPage ||
            index == _currentPage - 1 ||
            index == _currentPage + 1);

    if (shouldInitialize) {
      // Use WidgetsBinding to ensure we're not in build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_controllers.containsKey(index)) {
          _initializeController(video.videoUrl, index);
        }
      });
    }

    if (controller == null || !isInitialized) {
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
    if (_controllers.containsKey(index)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controllers[index] = controller;

    try {
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        _controllers.remove(index);
        return;
      }

      controller.setLooping(true);

      if (index == _currentPage) {
        controller.play();
      }

      setState(() {});
    } catch (e) {
      debugPrint('Error initializing video at index $index: $e');
      controller.dispose();
      _controllers.remove(index);

      // Retry once after a short delay
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !_controllers.containsKey(index)) {
            _initializeController(url, index);
          }
        });
      }
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
