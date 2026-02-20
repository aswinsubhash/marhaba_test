import '../../../../core/exports.dart';
import '../../domain/entities/video_entity.dart';
import '../../domain/repositories/video_repository.dart';
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
      final remoteVideos = await remoteDataSource.getVideos(
        page: page,
        limit: limit,
      );

      await _updateCache(remoteVideos, page);

      return (videos: remoteVideos, failure: null);
    } catch (e) {
      final cachedResult = await _getFromCache(page, limit);
      if (cachedResult != null) {
        return (videos: cachedResult, failure: null);
      }
      return (videos: null, failure: ServerFailure(message: e.toString()));
    }
  }

  Future<void> _updateCache(List<VideoModel> remoteVideos, int page) async {
    if (page == 1) {
      await localDataSource.cacheVideos(remoteVideos);
    } else {
      final cachedVideos = await localDataSource.getCachedVideos();
      final allVideos = [...cachedVideos, ...remoteVideos];
      await localDataSource.cacheVideos(allVideos);
    }
  }

  Future<List<VideoEntity>?> _getFromCache(int page, int limit) async {
    try {
      final cachedVideos = await localDataSource.getCachedVideos();
      if (cachedVideos.isEmpty) return null;

      final startIndex = (page - 1) * limit;
      if (startIndex >= cachedVideos.length) return null;

      final endIndex = startIndex + limit;
      return cachedVideos.sublist(
        startIndex,
        endIndex > cachedVideos.length ? cachedVideos.length : endIndex,
      );
    } catch (_) {
      return null;
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
