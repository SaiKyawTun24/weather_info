# Weather Info

A Flutter mobile weather search application powered by WeatherAPI.com.

## Requirements

- Flutter SDK with Dart 3.12 or newer
- A WeatherAPI.com API key

## Setup

1. Install dependencies:

	 ```bash
	 flutter pub get
	 ```

2. Create the local environment file:

	 ```powershell
	 Copy-Item .env.example .env
	 ```

3. Put your WeatherAPI.com key in `.env`:

	 ```text
	 BASE_URL=https://api.weatherapi.com/v1
	 API_KEY=your_weatherapi_key
	 ```

`.env` is ignored by Git. Never commit the real API key.

## Generate Code

This project uses `json_serializable` and Retrofit code generators. Run the
following command after changing annotated models or API service methods:

```bash
dart run build_runner build
```

During development, use watch mode to regenerate files automatically:

```bash
dart run build_runner watch
```

Generated files such as `weather_response.g.dart` and `api_service.g.dart`
should be regenerated before running or building the app.

## Run

```bash
flutter run
```

For a browser run:

```bash
flutter run -d chrome
```

## Test

```bash
flutter test
```

The test suite covers successful weather retrieval, API failure handling, and
favorite add/remove behavior.

## Architecture

- **State management:** Riverpod `NotifierProvider` owns the screen state and
	exposes search, retry, favorite, and recent-search actions.
- **Repository layer:** The notifier depends on the `Repository` abstraction,
	keeping API access separate from presentation logic.
- **Remote data:** Retrofit and Dio call WeatherAPI.com and convert responses
	into JSON-serializable models.
- **Local data:** `SharedPreferencesAsync` persists favorites and the ten most
	recent successful searches.

## Technical Decisions

- API keys are loaded at runtime through `flutter_dotenv` rather than stored in
	Dart source code.
- Loading and errors are represented in immutable `WeatherState` and shown in
	the UI with a progress indicator and retry action.
- Provider overrides make repository and storage behavior deterministic in
	tests without making network requests.

## Known Limitations

- The API key is still present in the client application at runtime, so this
	is not suitable for protecting a sensitive production credential. A backend
	proxy would be safer.
- Only current weather is displayed; forecasts, unit switching, and location
	auto-detection are not included.
- Favorites store city names rather than stable location IDs.

## Improvements With Additional Time

- Add a backend proxy and secure key management.
- Add forecast views, Celsius/Fahrenheit preferences, and pull-to-refresh.
- Add more widget tests for loading, retry, persistence, and responsive layout.

## Release Build

```bash
flutter build apk --release --split-per-abi --obfuscate --split-debug-info=build/debug-info
```