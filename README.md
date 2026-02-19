# Video Reels App

A Flutter application that displays video content in a reels-style vertical scrolling format with pagination, lazy loading, and caching capabilities.

## Features

- **Reels-style Video Player**: Smooth vertical scrolling video playback experience
- **Pagination**: Load more videos as you scroll
- **Lazy Loading**: Videos are loaded on demand for better performance
- **Caching**: Video data is cached locally to minimize API calls
- **Clean Architecture**: Proper separation of concerns with domain, data, and presentation layers
- **BLoC Pattern**: State management using flutter_bloc
- **Dependency Injection**: Using get_it for dependency management
- **Error Handling**: Graceful error handling with retry functionality
- **Pull to Refresh**: Refresh video content with pull-down gesture

## Architecture

This project follows Clean Architecture principles with three main layers:

```
lib/
├── core/
│   └── errors/
│       └── failures.dart          # Error handling classes
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
│               └── video_actions_widget.dart      # UI components
├── injection_container.dart        # Dependency injection setup
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

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
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
Contains shared utilities, error handling, and common functionality.

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

## Error Handling

- Network errors show cached data if available
- API errors display user-friendly messages
- Retry functionality for failed requests

## Video Player Features

- Tap to play/pause
- Auto-play on scroll
- Smooth transitions between videos
- Play/pause overlay indicator
- Video actions (like, share, comment, save)

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

## License

This project is open source and available under the MIT License.