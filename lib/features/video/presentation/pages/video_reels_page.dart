import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import '../../domain/entities/video_entity.dart';
import '../bloc/video_bloc.dart';
import '../bloc/video_event.dart';
import '../bloc/video_state.dart';

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

  @override
  void initState() {
    super.initState();
    context.read<VideoBloc>().add(const LoadVideos());
    _pageController.addListener(_onPageChanged);
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

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<VideoBloc, VideoState>(
        listener: (context, state) {
          if (state is VideoLoaded) {
            setState(() {
              _videos = state.videos;
            });
          } else if (state is VideoLoadingMore) {
            setState(() {
              _videos = state.videos;
            });
          }
        },
        builder: (context, state) {
          if (state is VideoLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
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
              color: Colors.white,
              backgroundColor: Colors.grey[900],
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification &&
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

          return const Center(
            child: Text(
              'No videos available',
              style: TextStyle(color: Colors.white),
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
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<VideoBloc>().add(const LoadVideos());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
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
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
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
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoInfo(VideoEntity video) {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${video.author}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            video.description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
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
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(20),
            child: const Icon(Icons.play_arrow, color: Colors.white, size: 48),
          ),
        ),
      ),
    );
  }
}
