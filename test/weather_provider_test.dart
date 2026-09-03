import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_info/data/local_storage/shared_preferences_service.dart';
import 'package:weather_info/data/model/weather_response.dart';
import 'package:weather_info/data/repository/repository.dart';
import 'package:weather_info/modules/home/provider/weather_provider.dart';

class _MockRepository extends Mock implements Repository {}

class _MockStorage extends Mock implements SharedPreferencesService {}

WeatherResponse _weather({String city = 'Yangon'}) {
  return WeatherResponse(
    location: Location(name: city, country: 'Myanmar'),
    current: Current(
      tempC: 30,
      humidity: 70,
      windKph: 10,
      condition: Condition(text: 'Partly cloudy'),
    ),
  );
}

ProviderContainer _createContainer({
  required Repository repository,
  required SharedPreferencesService storage,
}) {
  return ProviderContainer(
    overrides: [
      repositoryProvider.overrideWithValue(repository),
      sharedPreferencesServiceProvider.overrideWithValue(storage),
    ],
  );
}

void _stubEmptyStorage(_MockStorage storage) {
  when(() => storage.getFavorites()).thenAnswer((_) async => <String>[]);
  when(() => storage.getRecentSearches()).thenAnswer((_) async => <String>[]);
  when(() => storage.addRecentSearch(any())).thenAnswer((_) async {});
}

void main() {
  test('successfully retrieves and stores current weather', () async {
    final repository = _MockRepository();
    final storage = _MockStorage();
    _stubEmptyStorage(storage);
    when(
      () => repository.getCurrentWeather('Yangon'),
    ).thenAnswer((_) async => _weather());

    final container = _createContainer(
      repository: repository,
      storage: storage,
    );
    addTearDown(container.dispose);

    await container.read(weatherProvider.notifier).search('Yangon');
    final state = container.read(weatherProvider);

    expect(state.success, isTrue);
    expect(state.error, isFalse);
    expect(state.weather?.location?.name, 'Yangon');
    verify(() => repository.getCurrentWeather('Yangon')).called(1);
  });

  test('handles API failure with the server error message', () async {
    final repository = _MockRepository();
    final storage = _MockStorage();
    _stubEmptyStorage(storage);
    when(() => repository.getCurrentWeather('Unknown')).thenThrow(
      DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(path: '/current.json'),
        response: Response(
          statusCode: 400,
          data: <String, dynamic>{
            'error': <String, dynamic>{
              'message': 'No matching location found.',
            },
          },
          requestOptions: RequestOptions(path: '/current.json'),
        ),
      ),
    );

    final container = _createContainer(
      repository: repository,
      storage: storage,
    );
    addTearDown(container.dispose);

    await container.read(weatherProvider.notifier).search('Unknown');
    final state = container.read(weatherProvider);

    expect(state.error, isTrue);
    expect(state.success, isFalse);
    expect(state.errorMessage, 'No matching location found.');
    expect(state.weather, isNull);
  });

  test(
    'shows loading while retrieving weather and clears it afterwards',
    () async {
      final repository = _MockRepository();
      final storage = _MockStorage();
      _stubEmptyStorage(storage);
      final response = Completer<WeatherResponse>();
      when(
        () => repository.getCurrentWeather('Yangon'),
      ).thenAnswer((_) => response.future);

      final container = _createContainer(
        repository: repository,
        storage: storage,
      );
      addTearDown(container.dispose);
      final notifier = container.read(weatherProvider.notifier);
      final search = notifier.search('Yangon');

      await Future<void>.delayed(Duration.zero);
      expect(container.read(weatherProvider).isLoading, isTrue);

      response.complete(_weather());
      await search;
      expect(container.read(weatherProvider).isLoading, isFalse);
    },
  );

  test('retry repeats the last search query', () async {
    final repository = _MockRepository();
    final storage = _MockStorage();
    _stubEmptyStorage(storage);
    var attempts = 0;
    when(() => repository.getCurrentWeather('Yangon')).thenAnswer((_) async {
      attempts++;
      if (attempts == 1) {
        throw DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/current.json'),
        );
      }
      return _weather();
    });

    final container = _createContainer(
      repository: repository,
      storage: storage,
    );
    addTearDown(container.dispose);
    final notifier = container.read(weatherProvider.notifier);

    await notifier.search('Yangon');
    expect(container.read(weatherProvider).error, isTrue);

    await notifier.retry();
    expect(container.read(weatherProvider).success, isTrue);
    verify(() => repository.getCurrentWeather('Yangon')).called(2);
  });

  test('adds and removes the current city from favorites', () async {
    final repository = _MockRepository();
    final storage = _MockStorage();
    final favorites = <String>[];
    when(() => storage.getFavorites()).thenAnswer((_) async => [...favorites]);
    when(() => storage.getRecentSearches()).thenAnswer((_) async => <String>[]);
    when(() => storage.addRecentSearch(any())).thenAnswer((_) async {});
    when(
      () => storage.isFavorite('Yangon'),
    ).thenAnswer((_) async => favorites.contains('Yangon'));
    when(() => storage.addFavorite('Yangon')).thenAnswer((_) async {
      favorites.add('Yangon');
    });
    when(() => storage.removeFavorite('Yangon')).thenAnswer((_) async {
      favorites.remove('Yangon');
    });
    when(
      () => repository.getCurrentWeather('Yangon'),
    ).thenAnswer((_) async => _weather());

    final container = _createContainer(
      repository: repository,
      storage: storage,
    );
    addTearDown(container.dispose);
    final notifier = container.read(weatherProvider.notifier);

    await notifier.search('Yangon');
    await notifier.toggleFavorite();
    expect(container.read(weatherProvider).favorites, ['Yangon']);

    await notifier.toggleFavorite();
    expect(container.read(weatherProvider).favorites, isEmpty);
    verify(() => storage.addFavorite('Yangon')).called(1);
    verify(() => storage.removeFavorite('Yangon')).called(1);
  });
}
