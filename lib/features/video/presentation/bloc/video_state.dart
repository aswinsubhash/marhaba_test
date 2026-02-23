import '../../../../core/exports.dart';
import '../../domain/entities/video_entity.dart';

abstract class VideoState extends Equatable {
  final bool hasInternet;
  final bool isReconnecting;

  const VideoState({this.hasInternet = true, this.isReconnecting = false});

  @override
  List<Object?> get props => [hasInternet, isReconnecting];
}

class VideoInitial extends VideoState {
  const VideoInitial({super.hasInternet, super.isReconnecting});

  factory VideoInitial.create() => const VideoInitial();
}

class VideoLoading extends VideoState {
  const VideoLoading({super.hasInternet, super.isReconnecting});

  factory VideoLoading.create({
    bool hasInternet = true,
    bool isReconnecting = false,
  }) => VideoLoading(hasInternet: hasInternet, isReconnecting: isReconnecting);
}

class VideoLoaded extends VideoState {
  final List<VideoEntity> videos;
  final int currentPage;
  final bool hasReachedMax;

  const VideoLoaded({
    required this.videos,
    required this.currentPage,
    this.hasReachedMax = false,
    super.hasInternet,
    super.isReconnecting,
  });

  factory VideoLoaded.create({
    required List<VideoEntity> videos,
    required int currentPage,
    bool hasReachedMax = false,
    bool hasInternet = true,
    bool isReconnecting = false,
  }) {
    return VideoLoaded(
      videos: videos,
      currentPage: currentPage,
      hasReachedMax: hasReachedMax,
      hasInternet: hasInternet,
      isReconnecting: isReconnecting,
    );
  }

  @override
  List<Object?> get props => [
    videos,
    currentPage,
    hasReachedMax,
    hasInternet,
    isReconnecting,
  ];

  VideoLoaded copyWith({
    List<VideoEntity>? videos,
    int? currentPage,
    bool? hasReachedMax,
    bool? hasInternet,
    bool? isReconnecting,
  }) {
    return VideoLoaded(
      videos: videos ?? this.videos,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      hasInternet: hasInternet ?? this.hasInternet,
      isReconnecting: isReconnecting ?? this.isReconnecting,
    );
  }
}

class VideoError extends VideoState {
  final String message;

  const VideoError({
    required this.message,
    super.hasInternet,
    super.isReconnecting,
  });

  factory VideoError.create({
    required String message,
    bool hasInternet = true,
    bool isReconnecting = false,
  }) {
    return VideoError(
      message: message,
      hasInternet: hasInternet,
      isReconnecting: isReconnecting,
    );
  }

  @override
  List<Object?> get props => [message, hasInternet, isReconnecting];
}

class VideoLoadingMore extends VideoState {
  final List<VideoEntity> videos;
  final int currentPage;

  const VideoLoadingMore({
    required this.videos,
    required this.currentPage,
    super.hasInternet,
    super.isReconnecting,
  });

  factory VideoLoadingMore.create({
    required List<VideoEntity> videos,
    required int currentPage,
    bool hasInternet = true,
    bool isReconnecting = false,
  }) {
    return VideoLoadingMore(
      videos: videos,
      currentPage: currentPage,
      hasInternet: hasInternet,
      isReconnecting: isReconnecting,
    );
  }

  @override
  List<Object?> get props => [videos, currentPage, hasInternet, isReconnecting];
}

class VideoNoInternet extends VideoState {
  const VideoNoInternet();

  factory VideoNoInternet.create() => const VideoNoInternet();

  @override
  List<Object?> get props => [];
}
