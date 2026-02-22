import '../../../../core/exports.dart';

class VideoSkeletonLoader extends StatefulWidget {
  const VideoSkeletonLoader({super.key});

  @override
  State<VideoSkeletonLoader> createState() => _VideoSkeletonLoaderState();
}

class _VideoSkeletonLoaderState extends State<VideoSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: AppConstants.skeletonAnimationDurationMs,
      ),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding =
        AppConstants.videoInfoBottomPadding +
        AppConstants.videoInfoExtraBottomPadding;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned(
                bottom: bottomPadding,
                left: AppConstants.videoInfoHorizontalPadding,
                right: AppConstants.videoInfoHorizontalPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(
                      width: AppConstants.skeletonAuthorWidth,
                      height: AppConstants.font16,
                      borderRadius: AppConstants.radius8,
                    ),
                    const SizedBox(height: AppConstants.spacing8),
                    _buildShimmerBox(
                      width: AppConstants.skeletonTitleWidth,
                      height: AppConstants.font14,
                      borderRadius: AppConstants.radius8,
                    ),
                    const SizedBox(height: AppConstants.spacing4),
                    _buildShimmerBox(
                      width: AppConstants.skeletonDescriptionWidth,
                      height: AppConstants.font12,
                      borderRadius: AppConstants.radius8,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.grey900,
            AppColors.grey900.withValues(alpha: 0.5),
            AppColors.grey900,
          ],
          stops: [0.0, 0.5, 1.0],
          transform: _SlidingGradientTransform(slidePercent: _animation.value),
        ),
      ),
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
