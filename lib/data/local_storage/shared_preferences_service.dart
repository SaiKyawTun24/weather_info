import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesServiceProvider = Provider<SharedPreferencesService>((
  ref,
) {
  return SharedPreferencesService();
});

class SharedPreferencesService {
  final SharedPreferencesAsync _prefs;

  SharedPreferencesService() : _prefs = SharedPreferencesAsync();

  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  Future<double?> getDouble(String key) async {
    return _prefs.getDouble(key);
  }

  Future<void> saveStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  Future<List<String>?> getStringList(String key) async {
    return _prefs.getStringList(key);
  }

  Future<void> saveMap(String key, Map<String, dynamic> value) async {
    final jsonString = jsonEncode(value);
    await _prefs.setString(key, jsonString);
  }

  Future<Map<String, dynamic>?> getMap(String key) async {
    final jsonString = await _prefs.getString(key);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    final decoded = _decodeJson(jsonString);

    if (decoded is! Map) {
      return null;
    }

    return Map<String, dynamic>.from(decoded);
  }

  Future<void> saveObject<T>(
    String key,
    T object,
    Map<String, dynamic> Function(T object) toJson,
  ) async {
    final jsonString = jsonEncode(toJson(object));
    await _prefs.setString(key, jsonString);
  }

  Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final jsonString = await _prefs.getString(key);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    final decoded = _decodeJson(jsonString);

    if (decoded is! Map) {
      return null;
    }

    return fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<void> saveObjectList<T>(
    String key,
    List<T> list,
    Map<String, dynamic> Function(T object) toJson,
  ) async {
    final jsonList = list.map((item) => toJson(item)).toList();
    final jsonString = jsonEncode(jsonList);

    await _prefs.setString(key, jsonString);
  }

  Future<List<T>> getObjectList<T>(
    String key,
    T Function(Map<String, dynamic> json) fromJson,
  ) async {
    final jsonString = await _prefs.getString(key);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    final decoded = _decodeJson(jsonString);

    if (decoded is! List) {
      return [];
    }

    return decoded
        .whereType<Map>()
        .map((item) => fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Object? _decodeJson(String value) {
    try {
      return jsonDecode(value);
    } on FormatException {
      return null;
    }
  }

  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
