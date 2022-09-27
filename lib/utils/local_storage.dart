import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences? prefs;

  /// Get dynamic value from all type preferences
  static dynamic getFromDisk(String key, {bool decrypt = false}) {
    assert(prefs != null);
    var value = prefs?.get(key);
    if (value is List) return value.cast<String>();
    return value;
  }

  /// Save data function that handles all types
  static void saveToDisk<T>(String? key, T content, {bool encrypt = false}) {
    assert(prefs != null);
    if (content == null) {
      prefs?.remove(key!);
    }
    if (content is bool) {
      prefs?.setBool(key!, content);
    } else if (content is int) {
      prefs?.setInt(key!, content);
    } else if (content is String) {
      prefs?.setString(key!, content);
    } else if (content is double) {
      prefs?.setDouble(key!, content);
    } else if (content is List<String>) {
      prefs?.setStringList(key!, content);
    }
  }

  static void removeFromDisk(String? key, {bool clearAll = false}) {
    if (clearAll) {
      prefs?.clear();
    } else {
      saveToDisk(key, null);
    }
  }
}
