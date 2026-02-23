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
import '../widgets/error_widget.dart';
import '../widgets/video_skeleton_loader.dart';

class VideoReelsPage extends StatefulWidget {
  const VideoReelsPage({super.key});

  @override
  State<VideoReelsPage> createState() => _VideoReelsPageState();
}

class _VideoReelsPageState extends State<VideoReelsPage>
    with VideoControllerMixin {
  var _pageController = PageController();
  final _networkInfo = sl<NetworkInfo>();
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final hasInternet = await _networkInfo.isConnected;
    if (mounted) {
      if (hasInternet) {
        context.read<VideoBloc>().add(const LoadVideos());
      } else {
        context.read<VideoBloc>().add(const ConnectivityChanged(false));
      }
    }

    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen((
      connected,
    ) {
      if (mounted) {
        context.read<VideoBloc>().add(ConnectivityChanged(connected));
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _connectivitySubscription?.cancel();
    disposeAllControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.black,
    body: BlocConsumer<VideoBloc, VideoState>(
      listener: _handleListener,
      builder: _buildBody,
    ),
  );

  void _handleListener(BuildContext context, VideoState state) {
    if (state is VideoLoaded) {
      if (state.isReconnecting) {
        _pageController.dispose();
        _pageController = PageController();
        disposeAllControllers();
        currentPage = 0;
      }
    } else if (state is VideoNoInternet) {
      pauseAllVideos();
    }
  }

  Widget _buildBody(BuildContext context, VideoState state) {
    final bloc = context.read<VideoBloc>();

    if (state is VideoNoInternet) {
      return NoInternetWidget(
        onRetry: () async {
          final connected = await _networkInfo.isConnected;
          if (connected && mounted) {
            bloc.add(const ConnectivityChanged(true));
          }
        },
      );
    }

    if (state is VideoLoading) {
      return const VideoSkeletonLoader();
    }

    if (state is VideoError) {
      return ErrorDisplayWidget(
        message: state.message,
        onRetry: () => context.read<VideoBloc>().add(const LoadVideos()),
      );
    }

    if (state is VideoLoaded || state is VideoLoadingMore) {
      final videos = state is VideoLoaded
          ? state.videos
          : (state as VideoLoadingMore).videos;
      final hasReachedMax = state is VideoLoaded ? state.hasReachedMax : false;

      return RefreshIndicator(
        onRefresh: () async {
          currentPage = 0;
          disposeAllControllers();
          if (_pageController.hasClients) _pageController.jumpToPage(0);
          context.read<VideoBloc>().add(const RefreshVideos());
        },
        color: AppColors.white,
        backgroundColor: AppColors.grey900,
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: videos.length + (hasReachedMax ? 0 : 1),
          onPageChanged: (index) => _handlePageChange(index, videos),
          itemBuilder: (context, index) {
            if (index >= videos.length) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.white),
              );
            }
            return _buildVideoItem(videos[index], index);
          },
        ),
      );
    }

    return const VideoSkeletonLoader();
  }

  void _handlePageChange(int index, List<VideoEntity> videos) {
    if (index >= videos.length) return;

    controllers[currentPage]?.pause();
    playVideoFromStart(index);
    cleanupDistantControllers(index);

    if (videos.length - index <= 1) {
      final state = context.read<VideoBloc>().state;
      if (state is VideoLoaded && !state.hasReachedMax) {
        context.read<VideoBloc>().add(
          LoadMoreVideos(page: state.currentPage + 1),
        );
      }
    }

    currentPage = index;
    setState(() {});
  }

  Widget _buildVideoItem(VideoEntity video, int index) {
    final isInitialized = isControllerInitialized(index);
    final duration = getVideoDuration(index);
    final controller = controllers[index];

    if (controller == null && index == currentPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !controllers.containsKey(index)) {
          initializeController(video.videoUrl, index);
        }
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) => GestureDetector(
        onLongPressStart: (d) => startFastForward(
          index,
          d.localPosition,
          Size(constraints.maxWidth, constraints.maxHeight),
        ),
        onLongPressEnd: (_) => stopFastForward(),
        onLongPressCancel: stopFastForward,
        child: Stack(
          fit: StackFit.expand,
          children: [
            VideoPlayerWidget(
              controller: controller,
              isInitialized: isInitialized,
              onTap: () => togglePlayPause(index),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: AppConstants.gradientOverlayHeight,
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
            ),
            VideoInfoWidget(video: video),
            Visibility(
              visible: isInitialized,
              child: PlayPauseOverlay(
                isPlaying: isVideoPlaying(index),
                onTap: () => togglePlayPause(index),
              ),
            ),
            if (isInitialized && duration.inSeconds > 30 && controller != null)
              Positioned(
                bottom: AppConstants.progressBarBottomPosition,
                left: 0,
                right: 0,
                child: VideoProgressBar(controller: controller),
              ),
            Visibility(
              visible: isFastForwarding && fastForwardIndex == index,
              child: const FastForwardIndicator(),
            ),
          ],
        ),
      ),
    );
  }
}
