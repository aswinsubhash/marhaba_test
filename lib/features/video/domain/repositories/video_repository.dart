import '../entities/video_entity.dart';
import '../../../../core/errors/failures.dart';

abstract class VideoRepository {
  Future<({List<VideoEntity>? videos, Failure? failure})> getVideos({
    required int page,
    required int limit,
  });

  Future<({VideoEntity? video, Failure? failure})> getCachedVideo(String id);

  Future<Failure?> cacheVideos(List<VideoEntity> videos);
}
