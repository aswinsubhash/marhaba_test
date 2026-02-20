import '../../../../core/exports.dart';

class VideoPlayerWidget extends StatelessWidget {
  final VideoPlayerController? controller;
  final bool isInitialized;
  final VoidCallback? onTap;

  const VideoPlayerWidget({
    super.key,
    required this.controller,
    required this.isInitialized,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (controller == null || !isInitialized) {
      return Container(
        color: AppColors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.white),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller!.value.size.width,
          height: controller!.value.size.height,
          child: VideoPlayer(controller!),
        ),
      ),
    );
  }
}
