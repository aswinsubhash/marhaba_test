import '../../../../core/exports.dart';
import '../../domain/entities/video_entity.dart';

class VideoInfoWidget extends StatelessWidget {
  final VideoEntity video;

  const VideoInfoWidget({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    const bottomPadding =
        AppConstants.videoInfoBottomPadding + AppConstants.videoInfoExtraBottomPadding;

    return Positioned(
      bottom: bottomPadding,
      left: AppConstants.videoInfoHorizontalPadding,
      right: AppConstants.videoInfoHorizontalPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.author,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: AppConstants.font16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.spacing8),
          Text(
            video.title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: AppConstants.font14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppConstants.spacing4),
          Text(
            video.description,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.8),
              fontSize: AppConstants.font12,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
