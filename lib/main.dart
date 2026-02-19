import 'core/exports.dart';
import 'features/video/presentation/bloc/video_bloc.dart';
import 'features/video/presentation/pages/video_reels_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Video Reels',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (_) => sl<VideoBloc>(),
        child: const VideoReelsPage(),
      ),
    );
  }
}
