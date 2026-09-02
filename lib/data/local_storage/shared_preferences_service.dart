import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>((
  _,
) {
  return SharedPreferencesService();
});

class SharedPreferencesService {
  static const String _favoritesKey = 'favorite_cities';
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;

  final SharedPreferencesAsync _prefs;

  SharedPreferencesService() : _prefs = SharedPreferencesAsync();

  Future<List<String>> getFavorites() async {
    return await _readList(_favoritesKey);
  }

  Future<bool> isFavorite(String city) async {
    final normalizedCity = _normalizeCity(city);
    final favorites = await getFavorites();
    return favorites.contains(normalizedCity);
  }

  Future<void> addFavorite(String city) async {
    final normalizedCity = _normalizeCity(city);
    if (normalizedCity.isEmpty || await isFavorite(normalizedCity)) {
      return;
    }

    final favorites = await getFavorites();
    await _prefs.setStringList(_favoritesKey, [...favorites, normalizedCity]);
  }

  Future<void> removeFavorite(String city) async {
    final normalizedCity = _normalizeCity(city);
    final favorites = await getFavorites();
    favorites.remove(normalizedCity);
    await _prefs.setStringList(_favoritesKey, favorites);
  }

  Future<List<String>> getRecentSearches() async {
    return await _readList(_recentSearchesKey);
  }

  Future<void> addRecentSearch(String city) async {
    final normalizedCity = _normalizeCity(city);
    if (normalizedCity.isEmpty) {
      return;
    }

    final recentSearches = await getRecentSearches();
    recentSearches
      ..remove(normalizedCity)
      ..insert(0, normalizedCity);

    await _prefs.setStringList(
      _recentSearchesKey,
      recentSearches.take(_maxRecentSearches).toList(),
    );
  }

  Future<void> clearRecentSearches() async {
    await _prefs.remove(_recentSearchesKey);
  }

  Future<List<String>> _readList(String key) async {
    return await _prefs.getStringList(key) ?? <String>[];
  }

  String _normalizeCity(String city) {
    return city.trim();
  }
}
