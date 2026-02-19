import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_videos_usecase.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final GetVideosUseCase getVideosUseCase;

  VideoBloc({required this.getVideosUseCase}) : super(VideoInitial()) {
    on<LoadVideos>(_onLoadVideos);
    on<LoadMoreVideos>(_onLoadMoreVideos);
    on<RefreshVideos>(_onRefreshVideos);
  }

  Future<void> _onLoadVideos(LoadVideos event, Emitter<VideoState> emit) async {
    emit(VideoLoading());

    final result = await getVideosUseCase(page: event.page, limit: event.limit);

    if (result.videos != null) {
      emit(
        VideoLoaded(
          videos: result.videos!,
          currentPage: event.page,
          hasReachedMax: result.videos!.length < event.limit,
        ),
      );
    } else {
      emit(
        VideoError(
          message: result.failure?.message ?? 'Unknown error occurred',
        ),
      );
    }
  }

  Future<void> _onLoadMoreVideos(
    LoadMoreVideos event,
    Emitter<VideoState> emit,
  ) async {
    final currentState = state;

    if (currentState is VideoLoaded && currentState.hasReachedMax) {
      return;
    }

    if (currentState is VideoLoaded) {
      emit(
        VideoLoadingMore(
          videos: currentState.videos,
          currentPage: currentState.currentPage,
        ),
      );

      final result = await getVideosUseCase(
        page: event.page,
        limit: event.limit,
      );

      if (result.videos != null && result.videos!.isNotEmpty) {
        emit(
          VideoLoaded(
            videos: [...currentState.videos, ...result.videos!],
            currentPage: event.page,
            hasReachedMax: result.videos!.length < event.limit,
          ),
        );
      } else {
        emit(currentState.copyWith(hasReachedMax: true));
      }
    }
  }

  Future<void> _onRefreshVideos(
    RefreshVideos event,
    Emitter<VideoState> emit,
  ) async {
    emit(VideoLoading());

    final result = await getVideosUseCase(page: 1, limit: event.limit);

    if (result.videos != null) {
      emit(
        VideoLoaded(
          videos: result.videos!,
          currentPage: 1,
          hasReachedMax: result.videos!.length < event.limit,
        ),
      );
    } else {
      emit(
        VideoError(
          message: result.failure?.message ?? 'Unknown error occurred',
        ),
      );
    }
  }
}
