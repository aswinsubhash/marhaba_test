import '../../../../core/exports.dart';

class VideoEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String videoUrl;
  final String author;

  const VideoEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.author,
  });

  VideoEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? videoUrl,
    String? author,
  }) {
    return VideoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      videoUrl: videoUrl ?? this.videoUrl,
      author: author ?? this.author,
    );
  }

  @override
  List<Object?> get props => [id, title, description, videoUrl, author];
}
