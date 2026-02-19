import '../../../../core/exports.dart';
import '../../domain/entities/video_entity.dart';

part 'video_model.g.dart';

@HiveType(typeId: 0)
class VideoModel extends VideoEntity {
  const VideoModel({
    required super.id,
    required super.title,
    required super.description,
    required super.videoUrl,
    required super.author,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      videoUrl: json['video_url'] as String,
      author: json['author'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'video_url': videoUrl,
      'author': author,
    };
  }

  factory VideoModel.fromEntity(VideoEntity entity) {
    return VideoModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      videoUrl: entity.videoUrl,
      author: entity.author,
    );
  }
}
