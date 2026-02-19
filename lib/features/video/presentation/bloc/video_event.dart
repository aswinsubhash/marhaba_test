import '../../../../core/exports.dart';

abstract class VideoEvent extends Equatable {
  const VideoEvent();

  @override
  List<Object?> get props => [];
}

class LoadVideos extends VideoEvent {
  final int page;
  final int limit;

  const LoadVideos({this.page = 1, this.limit = 5});

  @override
  List<Object?> get props => [page, limit];
}

class LoadMoreVideos extends VideoEvent {
  final int page;
  final int limit;

  const LoadMoreVideos({required this.page, this.limit = 5});

  @override
  List<Object?> get props => [page, limit];
}

class RefreshVideos extends VideoEvent {
  final int limit;

  const RefreshVideos({this.limit = 5});

  @override
  List<Object?> get props => [limit];
}
