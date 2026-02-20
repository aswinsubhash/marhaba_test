import '../../../../core/exports.dart';

class FastForwardIndicator extends StatelessWidget {
  const FastForwardIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: AppConstants.fastForwardTopPosition,
      right: AppConstants.fastForwardRightPosition,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacing12,
          vertical: AppConstants.spacing4,
        ),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(AppConstants.radius16),
        ),
        child: const Text(
          Strings.fastForwardSpeed2x,
          style: TextStyle(
            color: AppColors.black,
            fontSize: AppConstants.font14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
