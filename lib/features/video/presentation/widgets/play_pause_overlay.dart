import '../../../../core/exports.dart';

class PlayPauseOverlay extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const PlayPauseOverlay({
    super.key,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Center(
        child: AnimatedOpacity(
          opacity: isPlaying ? 0.0 : 0.5,
          duration: const Duration(milliseconds: AppConstants.animationDuration200ms),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(AppConstants.playPauseOverlayPadding),
            child: const Icon(
              Icons.play_arrow,
              color: AppColors.white,
              size: AppConstants.icon48,
            ),
          ),
        ),
      ),
    );
  }
}
