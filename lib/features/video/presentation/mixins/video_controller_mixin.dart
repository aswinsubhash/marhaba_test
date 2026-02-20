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

      setState(() {});
    } catch (e) {
      debugPrint('Error initializing video at index $index: $e');
      controller.dispose();
      controllers.remove(index);

      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && !controllers.containsKey(index)) {
            initializeController(url, index);
          }
        });
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

  void playVideoFromStart(int index) {
    final controller = controllers[index];
    if (controller != null && controller.value.isInitialized) {
      controller.seekTo(Duration.zero);
      controller.play();
    }
  }

  void cleanupDistantControllers(int currentPageIndex) {
    if (controllers.length <= 10) return;

    final indicesToRemove = <int>[];
    const keepRange = 5;

    for (final index in controllers.keys) {
      if (index < currentPageIndex - keepRange ||
          index > currentPageIndex + keepRange) {
        indicesToRemove.add(index);
      }
    }

    for (final index in indicesToRemove) {
      final controller = controllers.remove(index);
      controller?.pause();
      controller?.dispose();
      debugPrint('Cleaned up controller at index $index');
    }
  }

  void startFastForward(int index, Offset localPosition, Size size) {
    if (localPosition.dx < size.width / 2) return;

    final controller = controllers[index];
    if (controller == null || !controller.value.isInitialized) return;

    controller.setPlaybackSpeed(2.0);
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
