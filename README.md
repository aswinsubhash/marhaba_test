# Video Reels App

A Flutter application that displays video content in a reels-style vertical scrolling format with pagination, lazy loading, caching capabilities, and robust offline/online connectivity handling.

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

## Building for Production

```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Author

**Aswin Subhash**
- GitHub: [@aswinsubhash](https://github.com/aswinsubhash)