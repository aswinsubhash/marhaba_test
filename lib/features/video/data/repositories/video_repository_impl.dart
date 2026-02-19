import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/video_repository.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/video_local_data_source.dart';
import '../datasources/video_remote_data_source.dart';
import '../models/video_model.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource remoteDataSource;
  final VideoLocalDataSource localDataSource;

  VideoRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<({List<VideoEntity>? videos, Failure? failure})> getVideos({
    required int page,
    required int limit,
  }) async {
    try {
      // Fetch from remote
      final remoteVideos = await remoteDataSource.getVideos(
        page: page,
        limit: limit,
      );

      // If first page, replace cache; otherwise append to cache
      if (page == 1) {
        await localDataSource.cacheVideos(remoteVideos);
      } else {
        // Get existing cached videos and append new ones
        final cachedVideos = await localDataSource.getCachedVideos();
        final allVideos = [...cachedVideos, ...remoteVideos];
        await localDataSource.cacheVideos(allVideos);
      }

      return (videos: remoteVideos, failure: null);
    } catch (e) {
      // On error, try to return cached data if available
      try {
        final cachedVideos = await localDataSource.getCachedVideos();
        if (cachedVideos.isNotEmpty) {
          final startIndex = (page - 1) * limit;
          final endIndex = startIndex + limit;
          if (startIndex < cachedVideos.length) {
            final paginatedVideos = cachedVideos.sublist(
              startIndex,
              endIndex > cachedVideos.length ? cachedVideos.length : endIndex,
            );
            return (videos: paginatedVideos, failure: null);
          }
        }
      } catch (_) {
        // Ignore cache errors
      }

      return (videos: null, failure: ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<({VideoEntity? video, Failure? failure})> getCachedVideo(
    String id,
  ) async {
    try {
      final video = await localDataSource.getCachedVideo(id);
      return (video: video, failure: null);
    } catch (e) {
      return (video: null, failure: CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> cacheVideos(List<VideoEntity> videos) async {
    try {
      final videoModels = videos
          .map((video) => VideoModel.fromEntity(video))
          .toList();
      await localDataSource.cacheVideos(videoModels);
      return null;
    } catch (e) {
      return CacheFailure(message: e.toString());
    }
  }
}
