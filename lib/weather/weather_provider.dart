import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/base_provider/base_provider.dart';
import '../core/base_provider/base_state.dart';
import '../data/api_service/api_service.dart';
import '../data/local_storage/shared_preferences_service.dart';
import '../data/model/weather_response.dart';
import '../data/repository/repository.dart';
import '../data/repository/repository_impl.dart';

final apiServiceProvider = Provider<ApiService>((_) => ApiService.create());

final repositoryProvider = Provider<Repository>((ref) {
  return RepositoryImpl(
    apiService: ref.watch(apiServiceProvider),
    sharedPreferencesService: ref.watch(sharedPreferencesServiceProvider),
  );
});

final weatherProvider = NotifierProvider<WeatherNotifier, WeatherState>(
  WeatherNotifier.new,
);

@immutable
class WeatherState extends BaseState {
  final WeatherResponse? weather;
  final String query;
  final String? errorMessage;
  final List<String> favorites;
  final List<String> recentSearches;

  const WeatherState({
    this.weather,
    this.query = '',
    this.errorMessage,
    this.favorites = const <String>[],
    this.recentSearches = const <String>[],
    super.initial = true,
    super.error = false,
    super.isLoading = false,
    super.success = false,
  });

  WeatherState withChanges({
    WeatherResponse? weather,
    String? query,
    String? errorMessage,
    bool clearErrorMessage = false,
    List<String>? favorites,
    List<String>? recentSearches,
    bool? initial,
    bool? error,
    bool? isLoading,
    bool? success,
  }) {
    return WeatherState(
      weather: weather ?? this.weather,
      query: query ?? this.query,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      favorites: favorites ?? this.favorites,
      recentSearches: recentSearches ?? this.recentSearches,
      initial: initial ?? this.initial,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
    );
  }
}

class WeatherNotifier extends BaseProvider<WeatherState> {
  late Repository _repository;
  late SharedPreferencesService _storage;

  @override
  WeatherState build() {
    _repository = ref.watch(repositoryProvider);
    _storage = ref.watch(sharedPreferencesServiceProvider);
    _loadSavedCities();
    return const WeatherState();
  }

  Future<void> search(String value) async {
    final city = value.trim();
    if (city.isEmpty) {
      state = state.withChanges(
        error: true,
        success: false,
        errorMessage: 'Enter a city name to search.',
      );
      return;
    }

    state = state.withChanges(
      query: city,
      error: false,
      success: false,
      clearErrorMessage: true,
    );

    final result = await callDataService(
      () => _repository.getCurrentWeather(city),
      onError: (exception) {
        state = state.withChanges(
          error: true,
          success: false,
          errorMessage: exception.message,
        );
      },
    );

    if (result == null) {
      return;
    }

    final searchedCity = result.location?.name?.trim() ?? city;
    await _storage.addRecentSearch(searchedCity);
    state = state.withChanges(
      weather: result,
      query: searchedCity,
      recentSearches: await _storage.getRecentSearches(),
      error: false,
      success: true,
      clearErrorMessage: true,
    );
  }

  Future<void> retry() async {
    if (state.query.isNotEmpty) {
      await search(state.query);
    }
  }

  Future<void> toggleFavorite() async {
    final city = state.weather?.location?.name?.trim();
    if (city == null || city.isEmpty) {
      return;
    }

    if (await _storage.isFavorite(city)) {
      await _storage.removeFavorite(city);
    } else {
      await _storage.addFavorite(city);
    }

    state = state.withChanges(favorites: await _storage.getFavorites());
  }

  Future<void> searchRecent(String city) => search(city);

  Future<void> clearRecentSearches() async {
    await _storage.clearRecentSearches();
    state = state.withChanges(recentSearches: const <String>[]);
  }

  Future<void> _loadSavedCities() async {
    final favorites = await _storage.getFavorites();
    final recentSearches = await _storage.getRecentSearches();
    state = state.withChanges(
      favorites: favorites,
      recentSearches: recentSearches,
      initial: false,
    );
  }

  @override
  void setLoading(bool value) {
    state = state.withChanges(isLoading: value, initial: false);
  }
}
