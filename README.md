# Video Reels App

A Flutter application that displays video content in a reels-style vertical scrolling format with pagination, lazy loading, caching capabilities, and robust offline/online connectivity handling.

## Requirements

- **Flutter SDK**: 3.41.0 (channel stable)
- **Dart SDK**: 3.11.0
- **DevTools**: 2.54.1

## Features

- **Reels-style Video Player**: Smooth vertical scrolling video playback experience
- **2x Fast Forward**: Long press on right side of screen to play at 2x speed
- **Video Progress Indicator**: Interactive progress bar for videos longer than 30 seconds
  - Tap to seek to any position
  - Drag to scrub through video
  - Automatic show/hide based on video duration
- **Pagination**: Load more videos as you scroll
- **Lazy Loading**: Videos are loaded on demand for better performance
- **Smart Memory Management**: Caches up to 10 video controllers for smooth back-navigation
- **Caching**: Video data is cached locally to minimize API calls
- **Offline Support**: Seamless handling of internet connectivity changes
  - Automatic video pause when internet is lost
  - No internet indicator with retry functionality
  - Automatic reconnection and video reload when internet is restored
- **Clean Architecture**: Proper separation of concerns with domain, data, and presentation layers
- **BLoC Pattern**: State management using flutter_bloc
- **Dependency Injection**: Using get_it for dependency management
- **Error Handling**: Graceful error handling with retry functionality
- **Pull to Refresh**: Refresh video content with pull-down gesture
- **Centralized Constants**: Organized constants for colors, sizes, strings, and app configuration

## Architecture

This project follows Clean Architecture principles with three main layers:

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_constants.dart       # App constants (sizes, durations, config)
│   │   ├── colors.dart              # App color constants
│   │   └── strings.dart             # String constants
│   ├── errors/
│   │   └── failures.dart            # Error handling classes
│   ├── network/
│   │   └── network_info.dart        # Network connectivity handling
│   └── exports.dart                 # Central exports file
├── features/
│   └── video/
│       ├── data/
│       │   ├── datasources/
│       │   │   ├── video_local_data_source.dart   # Local storage
│       │   │   └── video_remote_data_source.dart  # API calls
│       │   ├── models/
│       │   │   └── video_model.dart               # Data models
│       │   └── repositories/
│       │       └── video_repository_impl.dart     # Repository implementation
│       ├── domain/
│       │   ├── entities/
│       │   │   └── video_entity.dart              # Business entities
│       │   ├── repositories/
│       │   │   └── video_repository.dart          # Repository contracts
│       │   └── usecases/
│       │       └── get_videos_usecase.dart        # Use cases
│       └── presentation/
│           ├── bloc/
│           │   ├── video_bloc.dart                # BLoC
│           │   ├── video_event.dart               # Events
│           │   └── video_state.dart               # States
│           ├── mixins/
│           │   └── video_controller_mixin.dart    # Video controller logic
│           ├── pages/
│           │   └── video_reels_page.dart          # Main page
│           └── widgets/
│               ├── fast_forward_indicator.dart    # 2x speed indicator
│               ├── no_internet_widget.dart        # No internet indicator
│               ├── play_pause_overlay.dart        # Play/pause button
│               ├── video_info_widget.dart         # Video info overlay
│               ├── video_player_widget.dart       # Video player widget
│               └── video_progress_indicator.dart  # Video progress bar
├── dependency_injection.dart        # Dependency injection setup
└── main.dart                       # App entry point
```

## Dependencies

- **http**: HTTP requests
- **flutter_bloc**: State management
- **get_it**: Dependency injection
- **video_player**: Video playback
- **hive**: Local storage/caching
- **hive_flutter**: Hive Flutter integration
- **equatable**: Value equality
- **internet_connection_checker_plus**: Network connectivity

## Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/aswinsubhash/marhaba_test.git
   cd marhaba_test
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

## Project Structure

### Core Layer
Contains shared utilities, error handling, constants, network handling, and common functionality.

### Domain Layer
- **Entities**: Business objects with no dependencies
- **Repositories**: Abstract contracts for data operations
- **Use Cases**: Single-responsibility business logic

### Data Layer
- **Models**: Data transfer objects with serialization
- **Data Sources**: Remote (API) and Local (cache) data sources
- **Repository Implementations**: Concrete implementations of domain repositories

### Presentation Layer
- **BLoC**: State management with events and states
- **Mixins**: Reusable controller logic
- **Pages**: Screen-level widgets
- **Widgets**: Reusable UI components

## State Management

The app uses BLoC pattern with the following states:

- **VideoInitial**: Initial state
- **VideoLoading**: Loading videos
- **VideoLoaded**: Videos loaded successfully
- **VideoLoadingMore**: Loading additional videos
- **VideoError**: Error occurred

## Caching Strategy

1. Videos are cached locally using Hive
2. On app launch, cached data is displayed first
3. Fresh data is fetched from API in background
4. Cache is updated with new data

## Connectivity Handling

The app provides robust offline/online handling:

1. **Internet Lost**:
   - All videos are automatically paused
   - No internet indicator is displayed
   - Retry button available for manual reconnection

2. **Internet Restored**:
   - Videos are automatically reloaded
   - PageView is rebuilt with fresh data
   - First video starts playing automatically

## Video Player Features

- Tap to play/pause
- Long press right side for 2x speed
- Auto-play on scroll
- Smooth transitions between videos
- Play/pause overlay indicator
- Video looping
- Automatic retry on initialization failure
- Progress indicator for videos longer than 30 seconds

## Memory Management

- Caches up to 10 video controllers
- Automatic cleanup of distant controllers
- Smooth back-navigation experience

## Video Player Limitations

The app uses Flutter's `video_player` package which has some inherent limitations:

- **No Pre-buffering**: Videos cannot be pre-loaded in the background. Each video is initialized only when it becomes visible, causing a brief loading state when scrolling to new videos.

- **Memory Constraints**: Each video controller consumes significant memory, limiting us to caching ~10 controllers. Controllers outside the visible range (±5 videos) are automatically disposed.

- **Main Thread Initialization**: VideoPlayerController must be initialized on the main thread with the widget mounted in the tree, preventing background pre-loading.

- **Manual Lifecycle Management**: Controllers must be carefully disposed when widgets unmount to avoid memory leaks.

- **No Native Preload**: Unlike native solutions (ExoPlayer on Android, AVPlayer on iOS), Flutter's video_player doesn't support background preloading of multiple videos.

- **Third-Party Package Issues**: We explored `better_player` as an alternative with built-in caching, but it's not compatible with Flutter 3.11+ due to deprecated `hashValues` method usage.

### 🚧 Work in Progress: native_reels_player

I am currently developing a new Flutter plugin called **native_reels_player** to address these limitations:

- **Android**: Uses ExoPlayer for efficient video preloading and caching
- **iOS**: Uses AVPlayer with preload support
- **Features**:
  - Native preloading of a configurable range of videos
  - Better memory management with native-level caching
  - Smooth scrolling experience without loading indicators
  - Background video initialization

The plugin will be published on pub.dev once development is complete. Stay tuned for updates!

## Android Emulator Limitations

When running the app on an Android emulator, you may encounter the following issues with video playback:

- **Video Controller Initialization Failures**: Android emulators (especially older API levels) may fail to initialize video controllers properly. This is due to limited hardware acceleration support in the emulator.

- **Black Screen or No Video**: Some emulators may show a black screen or fail to render video content. This is a known issue with the emulator's video decoding capabilities.

- **Slow Video Loading**: Video initialization and buffering can be significantly slower on emulators compared to physical devices.

- **Memory Pressure**: Emulators have limited resources, which may cause video controllers to be disposed more frequently.

### Recommendations:
1. **Use iOS Simulator**: For a clean run without video playback issues, use the iOS Simulator.
2. **Use a Physical Device**: For best results, test video playback on a physical Android or iOS device.
3. **Use API Level 29+**: If you must use an Android emulator, use an AVD with API level 29 (Android 10) or higher.
4. **Enable Hardware Acceleration**: Ensure your emulator has hardware acceleration enabled (uses host GPU).
5. **Use x86_64 Images**: x86_64 system images tend to have better performance and video support.

## Building for Production

```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Author

**Aswin Subhash**
- GitHub: [@aswinsubhash](https://github.com/aswinsubhash)