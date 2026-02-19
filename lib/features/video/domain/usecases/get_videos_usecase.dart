import '../../../../core/exports.dart';
import '../entities/video_entity.dart';
import '../repositories/video_repository.dart';

class GetVideosUseCase {
  final VideoRepository repository;

  GetVideosUseCase(this.repository);

  Future<({List<VideoEntity>? videos, Failure? failure})> call({
    required int page,
    required int limit,
  }) {
    return repository.getVideos(page: page, limit: limit);
  }
}
