import '../../../../core/exports.dart';
import '../../domain/entities/video_entity.dart';

class VideoInfoWidget extends StatelessWidget {
  final VideoEntity video;

  const VideoInfoWidget({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    const bottomPadding = Sizes.videoInfoBottomPadding + 80;

    return Positioned(
      bottom: bottomPadding,
      left: Sizes.videoInfoHorizontalPadding,
      right: Sizes.videoInfoHorizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.author,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: Sizes.font16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Sizes.spacing8),
          Text(
            video.title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: Sizes.font14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: Sizes.spacing4),
          Text(
            video.description,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.8),
              fontSize: Sizes.font12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
