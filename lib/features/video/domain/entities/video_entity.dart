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

  @override
  List<Object?> get props => [id, title, description, videoUrl, author];
}
