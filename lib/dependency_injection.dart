import 'core/exports.dart';

import 'features/video/data/datasources/video_local_data_source.dart';
import 'features/video/data/datasources/video_remote_data_source.dart';
import 'features/video/data/repositories/video_repository_impl.dart';
import 'features/video/domain/repositories/video_repository.dart';
import 'features/video/domain/usecases/get_videos_usecase.dart';
import 'features/video/presentation/bloc/video_bloc.dart';
import 'features/video/data/models/video_model.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(VideoModelAdapter());

  // Features - Video
  // Bloc
  sl.registerFactory(() => VideoBloc(getVideosUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetVideosUseCase(sl()));

  // Repository
  sl.registerLazySingleton<VideoRepository>(
    () => VideoRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<VideoRemoteDataSource>(
    () => VideoRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<VideoLocalDataSource>(
    () => VideoLocalDataSourceImpl(),
  );

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnection()),
  );

  // External dependencies
  sl.registerLazySingleton(() => Client());
}
