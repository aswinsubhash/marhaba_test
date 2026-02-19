import '../../../../core/exports.dart';
import '../../domain/entities/video_entity.dart';

abstract class VideoState extends Equatable {
  const VideoState();

  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {
  const VideoInitial();

  factory VideoInitial.create() => const VideoInitial();
}

class VideoLoading extends VideoState {
  const VideoLoading();

  factory VideoLoading.create() => const VideoLoading();
}

class VideoLoaded extends VideoState {
  final List<VideoEntity> videos;
  final int currentPage;
  final bool hasReachedMax;

  const VideoLoaded({
    required this.videos,
    required this.currentPage,
    this.hasReachedMax = false,
  });

  factory VideoLoaded.create({
    required List<VideoEntity> videos,
    required int currentPage,
    bool hasReachedMax = false,
  }) {
    return VideoLoaded(
      videos: videos,
      currentPage: currentPage,
      hasReachedMax: hasReachedMax,
    );
  }

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

  factory VideoError.create({required String message}) {
    return VideoError(message: message);
  }

  @override
  List<Object?> get props => [message];
}

class VideoLoadingMore extends VideoState {
  final List<VideoEntity> videos;
  final int currentPage;

  const VideoLoadingMore({required this.videos, required this.currentPage});

  factory VideoLoadingMore.create({
    required List<VideoEntity> videos,
    required int currentPage,
  }) {
    return VideoLoadingMore(videos: videos, currentPage: currentPage);
  }

  @override
  List<Object?> get props => [videos, currentPage];
}
