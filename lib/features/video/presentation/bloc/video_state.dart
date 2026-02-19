import '../../../../core/exports.dart';
import '../../domain/entities/video_entity.dart';

abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideoLoaded extends VideoState {
  final List<VideoEntity> videos;
  final int currentPage;
  final bool hasReachedMax;

  const VideoLoaded({
    required this.videos,
    required this.currentPage,
    this.hasReachedMax = false,
  });

  VideoLoaded copyWith({
    List<VideoEntity>? videos,
    int? currentPage,
    bool? hasReachedMax,
  }) {
    return VideoLoaded(
      videos: videos ?? this.videos,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [videos, currentPage, hasReachedMax];
}

class VideoError extends VideoState {
  final String message;

  const VideoError({required this.message});

  @override
  List<Object?> get props => [message];
}

class VideoLoadingMore extends VideoState {
  final List<VideoEntity> videos;
  final int currentPage;

  const VideoLoadingMore({required this.videos, required this.currentPage});

  @override
  List<Object?> get props => [videos, currentPage];
}
