import '../../../../core/exports.dart';

mixin VideoControllerMixin<T extends StatefulWidget> on State<T> {
  final Map<int, VideoPlayerController> controllers = {};
  int currentPage = 0;
  bool isFastForwarding = false;
  int fastForwardIndex = -1;

  Future<void> initializeController(String url, int index) async {
    if (controllers.containsKey(index)) return;

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    controllers[index] = controller;

    try {
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        controllers.remove(index);
        return;
      }

      controller.setLooping(true);

      controller.addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

      if (index == currentPage) {
        controller.play();
      }
    } catch (e) {
      controller.dispose();
      controllers.remove(index);

      if (mounted) {
        Future.delayed(
          Duration(milliseconds: AppConstants.videoRetryDelayMs),
          () {
            if (mounted && !controllers.containsKey(index)) {
              initializeController(url, index);
            }
          },
        );
      }
    }
  }

  void togglePlayPause(int index) {
    final controller = controllers[index];
    if (controller == null || !controller.value.isInitialized) return;

    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    setState(() {});
  }

  void pauseAllVideos() {
    for (final controller in controllers.values) {
      if (controller.value.isInitialized) {
        controller.pause();
      }
    }
  }

  void disposeAllControllers() {
    for (final controller in controllers.values) {
      controller.pause();
      controller.dispose();
    }
    controllers.clear();
  }

  Future<void> playVideoFromStart(int index) async {
    final controller = controllers[index];
    if (controller != null && controller.value.isInitialized) {
      await controller.seekTo(Duration.zero);
      if (mounted) {
        controller.play();
      }
    }
  }

  void cleanupDistantControllers(int currentPageIndex) {
    if (controllers.length <= AppConstants.videoCacheMaxControllers) return;

    final indicesToRemove = <int>[];

    for (final index in controllers.keys) {
      if (index < currentPageIndex - AppConstants.videoCacheKeepRange ||
          index > currentPageIndex + AppConstants.videoCacheKeepRange) {
        indicesToRemove.add(index);
      }
    }

    for (final index in indicesToRemove) {
      final controller = controllers.remove(index);
      controller?.pause();
      controller?.dispose();
    }
  }

  void startFastForward(int index, Offset localPosition, Size size) {
    if (localPosition.dx < size.width / 2) return;

    final controller = controllers[index];
    if (controller == null || !controller.value.isInitialized) return;

    controller.setPlaybackSpeed(AppConstants.videoFastForwardSpeed);
    setState(() {
      isFastForwarding = true;
      fastForwardIndex = index;
    });
  }

  void stopFastForward() {
    if (!isFastForwarding) return;

    final controller = controllers[fastForwardIndex];
    if (controller != null && controller.value.isInitialized) {
      controller.setPlaybackSpeed(1.0);
    }

    setState(() {
      isFastForwarding = false;
      fastForwardIndex = -1;
    });
  }

  bool isControllerInitialized(int index) {
    final controller = controllers[index];
    return controller?.value.isInitialized ?? false;
  }

  Duration getVideoDuration(int index) {
    final controller = controllers[index];
    return controller?.value.duration ?? Duration.zero;
  }

  bool isVideoPlaying(int index) {
    final controller = controllers[index];
    return controller?.value.isPlaying ?? false;
  }
}
