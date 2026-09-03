import 'package:flutter_test/flutter_test.dart';
import 'package:weather_info/data/local_storage/shared_preferences_service.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  test('favorites persist when the storage service is recreated', () async {
    const city = 'Persistence Test City';
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final firstSession = SharedPreferencesService();
    final secondSession = SharedPreferencesService();

    await firstSession.removeFavorite(city);
    await firstSession.addFavorite(city);

    expect(await secondSession.getFavorites(), contains(city));

    await secondSession.removeFavorite(city);
    expect(await firstSession.getFavorites(), isNot(contains(city)));
  });

  test('recent searches are newest first and limited to ten entries', () async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    final storage = SharedPreferencesService();

    for (var index = 1; index <= 11; index++) {
      await storage.addRecentSearch('City $index');
    }

    final recentSearches = await storage.getRecentSearches();
    expect(recentSearches, hasLength(10));
    expect(recentSearches.first, 'City 11');
    expect(recentSearches.last, 'City 2');
  });
}
