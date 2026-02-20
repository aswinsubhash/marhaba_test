import '../../../../core/exports.dart';

class FastForwardIndicator extends StatelessWidget {
  const FastForwardIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: Sizes.fastForwardTopPosition,
      right: Sizes.fastForwardRightPosition,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Sizes.spacing12,
          vertical: Sizes.spacing4,
        ),
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(Sizes.fastForwardBadgeRadius),
        ),
        child: const Text(
          '2x',
          style: TextStyle(
            color: AppColors.black,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
