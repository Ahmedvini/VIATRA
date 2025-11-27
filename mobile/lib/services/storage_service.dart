import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Storage service for managing app data persistence
class StorageService {
  factory StorageService() => _instance;
  StorageService._internal();
  static final StorageService _instance = StorageService._internal();

  SharedPreferences? _prefs;
  
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Initialize storage service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensure preferences are initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }

  // Regular storage methods (SharedPreferences)

  /// Set string value
  Future<bool> setString(String key, String value) async {
    await _ensureInitialized();
    return _prefs!.setString(key, value);
  }

  /// Get string value
  Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs!.getString(key);
  }

  /// Set integer value
  Future<bool> setInt(String key, int value) async {
    await _ensureInitialized();
    return _prefs!.setInt(key, value);
  }

  /// Get integer value
  Future<int?> getInt(String key) async {
    await _ensureInitialized();
    return _prefs!.getInt(key);
  }

  /// Set double value
  Future<bool> setDouble(String key, double value) async {
    await _ensureInitialized();
    return _prefs!.setDouble(key, value);
  }

  /// Get double value
  Future<double?> getDouble(String key) async {
    await _ensureInitialized();
    return _prefs!.getDouble(key);
  }

  /// Set boolean value
  Future<bool> setBool(String key, bool value) async {
    await _ensureInitialized();
    return _prefs!.setBool(key, value);
  }

  /// Get boolean value
  Future<bool?> getBool(String key) async {
    await _ensureInitialized();
    return _prefs!.getBool(key);
  }

  /// Set list of strings
  Future<bool> setStringList(String key, List<String> value) async {
    await _ensureInitialized();
    return _prefs!.setStringList(key, value);
  }

  /// Get list of strings
  Future<List<String>?> getStringList(String key) async {
    await _ensureInitialized();
    return _prefs!.getStringList(key);
  }

  /// Set JSON object (automatically serialized)
  Future<bool> setValue(String key, dynamic value) async {
    await _ensureInitialized();
    final jsonString = jsonEncode(value);
    return _prefs!.setString(key, jsonString);
  }

  /// Get JSON object (automatically deserialized)
  Future<dynamic> getValue(String key) async {
    await _ensureInitialized();
    final jsonString = _prefs!.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Remove value
  Future<bool> remove(String key) async {
    await _ensureInitialized();
    return _prefs!.remove(key);
  }

  /// Remove value (alias for remove)
  Future<bool> removeValue(String key) async => remove(key);

  /// Check if key exists
  Future<bool> containsKey(String key) async {
    await _ensureInitialized();
    return _prefs!.containsKey(key);
  }

  /// Get all keys
  Future<Set<String>> getKeys() async {
    await _ensureInitialized();
    return _prefs!.getKeys();
  }

  /// Clear all data
  Future<bool> clear() async {
    await _ensureInitialized();
    return _prefs!.clear();
  }

  // Secure storage methods (FlutterSecureStorage)

  /// Set secure value (encrypted)
  Future<void> setSecureValue(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  /// Get secure value (decrypted)
  Future<String?> getSecureValue(String key) async => await _secureStorage.read(key: key);

  /// Remove secure value
  Future<void> removeSecureValue(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Check if secure key exists
  Future<bool> containsSecureKey(String key) async => await _secureStorage.containsKey(key: key);

  /// Get all secure keys
  Future<Map<String, String>> getAllSecureValues() async => await _secureStorage.readAll();

  /// Clear all secure data
  Future<void> clearSecureStorage() async {
    await _secureStorage.deleteAll();
  }

  // Convenience methods

  /// Store user preferences
  Future<void> setUserPreference(String key, dynamic value) async {
    await setValue('user_pref_$key', value);
  }

  /// Get user preferences
  Future<T?> getUserPreference<T>(String key) async => await getValue('user_pref_$key') as T?;

  /// Remove user preference
  Future<bool> removeUserPreference(String key) async => await remove('user_pref_$key');

  /// Store app settings
  Future<void> setAppSetting(String key, dynamic value) async {
    await setValue('app_setting_$key', value);
  }

  /// Get app settings
  Future<T?> getAppSetting<T>(String key) async => await getValue('app_setting_$key') as T?;

  /// Store cache data with TTL (Time To Live)
  Future<void> setCacheData(String key, dynamic value, {Duration? ttl}) async {
    final cacheData = {
      'value': value,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'ttl': ttl?.inMilliseconds,
    };
    await setValue('cache_$key', cacheData);
  }

  /// Get cache data (returns null if expired)
  Future<T?> getCacheData<T>(String key) async {
    final cacheData = await getValue('cache_$key');
    if (cacheData == null) return null;

    final timestamp = cacheData['timestamp'] as int?;
    final ttl = cacheData['ttl'] as int?;
    
    if (timestamp != null && ttl != null) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > ttl) {
        // Cache expired, remove it
        await remove('cache_$key');
        return null;
      }
    }
    
    return cacheData['value'] as T?;
  }

  /// Clear expired cache data
  Future<void> clearExpiredCache() async {
    final keys = await getKeys();
    final now = DateTime.now().millisecondsSinceEpoch;
    
    for (final key in keys) {
      if (key.startsWith('cache_')) {
        final cacheData = await getValue(key);
        if (cacheData != null) {
          final timestamp = cacheData['timestamp'] as int?;
          final ttl = cacheData['ttl'] as int?;
          
          if (timestamp != null && ttl != null && now - timestamp > ttl) {
            await remove(key);
          }
        }
      }
    }
  }

  /// Get storage usage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    await _ensureInitialized();
    final keys = _prefs!.getKeys();
    
    var totalSize = 0;
    final categories = <String, int>{};
    
    for (final key in keys) {
      final value = _prefs!.get(key);
      final size = value.toString().length;
      totalSize += size;
      
      var category = 'other';
      if (key.startsWith('user_pref_')) {
        category = 'user_preferences';
      } else if (key.startsWith('app_setting_')) {
        category = 'app_settings';
      } else if (key.startsWith('cache_')) {
        category = 'cache';
      }
      
      categories[category] = (categories[category] ?? 0) + size;
    }
    
    return {
      'total_keys': keys.length,
      'total_size_bytes': totalSize,
      'categories': categories,
    };
  }
}
