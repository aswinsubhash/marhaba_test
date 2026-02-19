# Video Reels App

A Flutter application that displays video content in a reels-style vertical scrolling format with pagination, lazy loading, caching capabilities, and robust offline/online connectivity handling.

## Features

- **Reels-style Video Player**: Smooth vertical scrolling video playback experience
- **Pagination**: Load more videos as you scroll
- **Lazy Loading**: Videos are loaded on demand for better performance
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
- **Centralized Constants**: Organized constants for colors, sizes, and strings

## Architecture

This project follows Clean Architecture principles with three main layers:

```
lib/
├── core/
│   ├── constants/
│   │   ├── colors.dart              # App color constants
│   │   ├── sizes.dart               # Size constants
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
│           ├── pages/
│           │   └── video_reels_page.dart          # Main page
│           └── widgets/
│               └── no_internet_widget.dart        # No internet indicator
├── dependency_injection.dart        # Dependency injection setup
└── main.dart                       # App entry point
```

## Dependencies

- **http**: HTTP requests
- **flutter_bloc**: State management
- **get_it**: Dependency injection
- **video_player**: Video playback
- **shared_preferences**: Local caching
- **equatable**: Value equality
- **connectivity_plus**: Network connectivity
- **dartz**: Functional programming

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
- **Pages**: Screen-level widgets
- **Widgets**: Reusable UI components

## API Integration

The app is configured to work with a video API. The expected response format:

```json
{
  "status": "success",
  "page": 1,
  "limit": 10,
  "total_pages": 1,
  "data": [
    {
      "id": "byte_001",
      "title": "Video Title",
      "description": "Video description",
      "video_url": "https://example.com/video.mp4",
      "author": "Author Name",
      "likes": 1240,
      "shares": 45
    }
  ]
}
```

To use a real API endpoint, update the URL in `video_remote_data_source.dart`:

```dart
final response = await client.get(
  Uri.parse('YOUR_API_ENDPOINT?page=$page&limit=$limit'),
);
```

## State Management

The app uses BLoC pattern with the following states:

- **VideoInitial**: Initial state
- **VideoLoading**: Loading videos
- **VideoLoaded**: Videos loaded successfully
- **VideoLoadingMore**: Loading additional videos
- **VideoError**: Error occurred

## Caching Strategy

1. Videos are cached locally using SharedPreferences
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
- Auto-play on scroll
- Smooth transitions between videos
- Play/pause overlay indicator
- Video looping
- Preloading of adjacent videos for smooth scrolling
- Automatic retry on initialization failure

## Running Tests

```bash
flutter test
```

## Building for Production

```bash
flutter build apk --release  # Android
flutter build ios --release  # iOS
```

## Requirements Met

- [x] HTTP package for API requests
- [x] JSON response parsing using Dart's built-in decoding
- [x] Pagination for loading additional content
- [x] Lazy loading for improved performance
- [x] Caching for video data
- [x] Error handling during API calls and JSON parsing
- [x] Proper asynchronous programming
- [x] Clear separation between UI and business logic
- [x] Reels-style video page with vertical scrolling
- [x] Clean Architecture implementation
- [x] BLoC pattern for state management
- [x] Dependency Injection using get_it
- [x] Offline/Online connectivity handling
- [x] Centralized constants management
- [x] Automatic video pause on connectivity loss
- [x] Automatic reconnection handling

## Recent Updates

### v1.1.0
- Added centralized constants for colors, sizes, and strings
- Implemented robust offline/online connectivity handling
- Fixed video reconnection issues when coming back online
- Added UniqueKey-based PageView rebuild for proper state reset
- Improved video initialization with post-frame callbacks
- Added automatic retry mechanism for failed video initializations

## License

This project is open source and available under the MIT License.

## Author

**Aswin Subhash**
- GitHub: [@aswinsubhash](https://github.com/aswinsubhash)