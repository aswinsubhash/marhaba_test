import '../../../../core/exports.dart';
import '../../domain/entities/video_entity.dart';
import '../bloc/video_bloc.dart';
import '../bloc/video_event.dart';
import '../bloc/video_state.dart';
import '../mixins/video_controller_mixin.dart';
import '../widgets/fast_forward_indicator.dart';
import '../widgets/no_internet_widget.dart';
import '../widgets/play_pause_overlay.dart';
import '../widgets/video_info_widget.dart';
import '../widgets/video_player_widget.dart';
import '../widgets/video_progress_indicator.dart';

class VideoReelsPage extends StatefulWidget {
  const VideoReelsPage({super.key});

  @override
  State<VideoReelsPage> createState() => _VideoReelsPageState();
}

class _VideoReelsPageState extends State<VideoReelsPage>
    with VideoControllerMixin {
  PageController _pageController = PageController();
  List<VideoEntity> _videos = [];
  bool _hasInternet = true;
  bool _isReconnecting = false;
  bool _wasDisconnected = false;
  StreamSubscription<bool>? _connectivitySubscription;
  UniqueKey _pageViewKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _checkInternetAndLoad();
    _listenToConnectivity();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _connectivitySubscription?.cancel();
    disposeAllControllers();
    super.dispose();
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
        pauseAllVideos();
        setState(() {
          _hasInternet = false;
          _isReconnecting = false;
          _wasDisconnected = true;
        });
      } else if (_wasDisconnected) {
        setState(() {
          _isReconnecting = true;
        });
        _handleReconnection();
      }
    });
  }

  void _handleReconnection() {
    disposeAllControllers();
    currentPage = 0;

    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    _pageController = PageController();
    _pageController.addListener(_onPageChanged);

    _pageViewKey = UniqueKey();

    setState(() {
      _videos = [];
    });

    context.read<VideoBloc>().add(const LoadVideos());
  }

  void _onPageChanged() {
    if (!_pageController.hasClients) return;
    final newPage = _pageController.page?.round() ?? 0;
    if (newPage != currentPage) {
      _handlePageChange(newPage);
    }
  }

  void _handlePageChange(int newPage) {
    controllers[currentPage]?.pause();
    playVideoFromStart(newPage);
    cleanupDistantControllers(newPage);

    if (_videos.length - newPage <= 1) {
      final state = context.read<VideoBloc>().state;
      _loadMoreVideos(state);
    }

    setState(() {
      currentPage = newPage;
    });
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
          if (!_hasInternet) {
            return NoInternetWidget(onRetry: _retryInternetConnection);
          }

          if (_isReconnecting || state is VideoLoading || _videos.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.white),
            );
          }

          if (state is VideoError) {
            return _buildErrorWidget(state.message);
          }

          if (_videos.isNotEmpty) {
            return _buildPageView(state);
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

  Widget _buildPageView(VideoState state) {
    return RefreshIndicator(
      onRefresh: () async {
        currentPage = 0;
        disposeAllControllers();

        if (_pageController.hasClients) {
          _pageController.jumpToPage(0);
        }

        context.read<VideoBloc>().add(const RefreshVideos());
      },
      color: AppColors.white,
      backgroundColor: AppColors.grey900,
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
    final isInitialized = isControllerInitialized(index);
    final duration = getVideoDuration(index);
    final showProgressBar = isInitialized && duration.inSeconds > 30;

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onLongPressStart: (details) {
            startFastForward(
              index,
              details.localPosition,
              Size(constraints.maxWidth, constraints.maxHeight),
            );
          },
          onLongPressEnd: (_) => stopFastForward(),
          onLongPressCancel: () => stopFastForward(),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildVideoPlayer(video, index),
              _buildGradientOverlay(),
              VideoInfoWidget(video: video),
              if (isInitialized)
                PlayPauseOverlay(
                  isPlaying: isVideoPlaying(index),
                  onTap: () => togglePlayPause(index),
                ),
              if (showProgressBar) _buildProgressBar(index),
              if (isFastForwarding && fastForwardIndex == index)
                const FastForwardIndicator(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoPlayer(VideoEntity video, int index) {
    final controller = controllers[index];
    final isInitialized = isControllerInitialized(index);

    final shouldInitialize = controller == null && index == currentPage;

    if (shouldInitialize) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !controllers.containsKey(index)) {
          initializeController(video.videoUrl, index);
        }
      });
    }

    return VideoPlayerWidget(
      controller: controller,
      isInitialized: isInitialized,
      onTap: () => togglePlayPause(index),
    );
  }

  Widget _buildProgressBar(int index) {
    final controller = controllers[index];
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: Sizes.progressBarBottomPosition,
      left: 0,
      right: 0,
      child: VideoProgressBar(controller: controller),
    );
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
}
