import 'package:hive_flutter/hive_flutter.dart';
import '../models/video_model.dart';

abstract class VideoLocalDataSource {
  Future<List<VideoModel>> getCachedVideos();
  Future<VideoModel?> getCachedVideo(String id);
  Future<void> cacheVideos(List<VideoModel> videos);
  Future<void> clearCache();
}

class VideoLocalDataSourceImpl implements VideoLocalDataSource {
  static const String _boxName = 'videos_box';
  static const String _videosKey = 'cached_videos';
  Box<dynamic>? _box;

  VideoLocalDataSourceImpl();

  Future<Box<dynamic>> _getBox() async {
    _box ??= await Hive.openBox(_boxName);
    return _box!;
  }

  @override
  Future<List<VideoModel>> getCachedVideos() async {
    final box = await _getBox();
    final List<dynamic>? videosList = box.get(_videosKey) as List<dynamic>?;
    if (videosList != null) {
      return videosList.cast<VideoModel>();
    }
    return [];
  }

  @override
  Future<VideoModel?> getCachedVideo(String id) async {
    final videos = await getCachedVideos();
    try {
      return videos.firstWhere((video) => video.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheVideos(List<VideoModel> videos) async {
    final box = await _getBox();
    await box.put(_videosKey, videos);
  }

  @override
  Future<void> clearCache() async {
    final box = await _getBox();
    await box.delete(_videosKey);
  }
}
