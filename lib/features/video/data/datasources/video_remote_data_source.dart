import '../../../../core/exports.dart';
import '../models/video_model.dart';

abstract class VideoRemoteDataSource {
  Future<List<VideoModel>> getVideos({required int page, required int limit});
}

class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final Client client;

  VideoRemoteDataSourceImpl({required this.client});

  // Mock data for pagination testing
  static final List<Map<String, dynamic>> _mockVideos = [
    {
      "id": "byte_001",
      "title": "For Bigger Fun",
      "description": "A fun short video for reels testing.",
      "video_url":
          "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
      "author": "Google",
    },
    {
      "id": "byte_002",
      "title": "For Bigger Blazes",
      "description": "High quality sample video.",
      "video_url":
          "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
      "author": "Google",
    },
    {
      "id": "byte_003",
      "title": "For Bigger Joyrides",
      "description": "Smooth vertical scrolling test.",
      "video_url":
          "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
      "author": "Google",
    },
    {
      "id": "byte_004",
      "title": "Elephants Dream",
      "description": "Open source movie sample.",
      "video_url":
          "https://storage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
      "author": "Blender",
    },
    {
      "id": "byte_005",
      "title": "Big Buck Bunny",
      "description": "Classic animation for video playback testing.",
      "video_url":
          "https://storage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
      "author": "Blender",
    },
    {
      "id": "byte_006",
      "title": "For Bigger Escapes",
      "description": "Testing lazy loading and caching.",
      "video_url":
          "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
      "author": "Google",
    },
    {
      "id": "byte_007",
      "title": "For Bigger Meltdowns",
      "description": "Network request simulation.",
      "video_url":
          "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
      "author": "Google",
    },
    {
      "id": "byte_008",
      "title": "Subaru Outback",
      "description": "On street and dirt.",
      "video_url":
          "https://storage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
      "author": "Garage",
    },
    {
      "id": "byte_009",
      "title": "Tears Of Steel",
      "description": "Sci-fi short film.",
      "video_url":
          "https://storage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
      "author": "Blender",
    },
    {
      "id": "byte_010",
      "title": "Volkswagen GTI",
      "description": "Car review sample.",
      "video_url":
          "https://storage.googleapis.com/gtv-videos-bucket/sample/VolkswagenGTIReview.mp4",
      "author": "Garage",
    },
    {
      "id": "byte_011",
      "title": "Flutter Butterfly",
      "description": "Official Flutter API test video.",
      "video_url":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4",
      "author": "Flutter",
    },
    {
      "id": "byte_012",
      "title": "Flutter Bee",
      "description": "Official Flutter API test video.",
      "video_url":
          "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      "author": "Flutter",
    },
    {
      "id": "byte_013",
      "title": "Bullrun",
      "description": "Google sample video.",
      "video_url":
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4",
      "author": "Google",
    },
    {
      "id": "byte_014",
      "title": "Car for a Grand",
      "description": "Google sample car review.",
      "video_url":
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WhatCarCanYouGetForAGrand.mp4",
      "author": "Garage",
    },
    {
      "id": "byte_015",
      "title": "Sintel",
      "description": "Open source movie sample.",
      "video_url":
          "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
      "author": "Blender",
    },
    {
      "id": "byte_016",
      "title": "Sintel Trailer",
      "description": "W3C standard test video.",
      "video_url": "https://media.w3.org/2010/05/sintel/trailer.mp4",
      "author": "W3C",
    },
    {
      "id": "byte_017",
      "title": "Bunny Trailer",
      "description": "W3C standard test video.",
      "video_url": "https://media.w3.org/2010/05/bunny/trailer.mp4",
      "author": "W3C",
    },
    {
      "id": "byte_018",
      "title": "Big Buck Bunny W3Schools",
      "description": "W3Schools HTML video test.",
      "video_url": "https://www.w3schools.com/html/mov_bbb.mp4",
      "author": "W3Schools",
    },
  ];

  @override
  Future<List<VideoModel>> getVideos({
    required int page,
    required int limit,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate pagination
    final startIndex = (page - 1) * limit;
    if (startIndex >= _mockVideos.length) {
      return [];
    }

    final endIndex = startIndex + limit;
    final paginatedJson = _mockVideos.sublist(
      startIndex,
      endIndex > _mockVideos.length ? _mockVideos.length : endIndex,
    );

    return paginatedJson.map((json) => VideoModel.fromJson(json)).toList();
  }
}
