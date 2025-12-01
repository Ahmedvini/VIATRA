import 'package:flutter/foundation.dart';
import '../models/health_profile_model.dart';
import '../services/health_profile_service.dart';
import '../services/storage_service.dart';

enum HealthProfileState {
  initial,
  loading,
  loaded,
  error,
}

class HealthProfileProvider extends ChangeNotifier {

  HealthProfileProvider({
    required HealthProfileService healthProfileService,
    required StorageService storageService,
  })  : _healthProfileService = healthProfileService,
        _storageService = storageService;
  final HealthProfileService _healthProfileService;
  final StorageService _storageService;

  HealthProfileState _state = HealthProfileState.initial;
  HealthProfile? _healthProfile;
  String? _errorMessage;
  DateTime? _lastFetchTime;

  static const String _cacheKey = 'health_profile_cache';
  static const Duration _cacheDuration = Duration(minutes: 5);

  // Getters
  HealthProfileState get state => _state;
  HealthProfile? get healthProfile => _healthProfile;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == HealthProfileState.loading;
  bool get hasProfile => _healthProfile != null;

  // Set state and notify listeners
  void _setState(HealthProfileState newState) {
    _state = newState;
    notifyListeners();
  }

  // Set error and notify listeners
  void _setError(String message) {
    _errorMessage = message;
    _setState(HealthProfileState.error);
  }

  // Check if cache is still valid
  bool _isCacheValid() {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheDuration;
  }

  // Load health profile with caching
  Future<void> loadHealthProfile({bool forceRefresh = false}) async {
    try {
      // Check cache first if not forcing refresh
      if (!forceRefresh && _isCacheValid() && _healthProfile != null) {
        _setState(HealthProfileState.loaded);
        return;
      }

      // Try to load from persistent cache
      if (!forceRefresh) {
        final cachedData = await _storageService.getCacheData(_cacheKey);
        if (cachedData != null) {
          try {
            _healthProfile = HealthProfile.fromJson(cachedData as Map<String, dynamic>);
            _lastFetchTime = DateTime.now();
            _setState(HealthProfileState.loaded);
            return;
          } catch (e) {
            // Cache is invalid, continue to fetch from API
            debugPrint('Invalid cache data: $e');
          }
        }
      }

      // Fetch from API
      _setState(HealthProfileState.loading);
      
      final response = await _healthProfileService.getMyHealthProfile();

      if (response.success && response.data != null) {
        _healthProfile = response.data;
        _lastFetchTime = DateTime.now();
        _errorMessage = null;

        // Cache the result
        await _storageService.setCacheData(
          _cacheKey,
          _healthProfile!.toJson(),
          ttl: _cacheDuration,
        );

        _setState(HealthProfileState.loaded);
      } else {
        _setError(response.message ?? 'Failed to load health profile');
      }
    } catch (e) {
      _setError('An error occurred: $e');
    }
  }

  // Create health profile
  Future<bool> createHealthProfile(HealthProfile profile) async {
    try {
      _setState(HealthProfileState.loading);

      final response = await _healthProfileService.createHealthProfile(profile);

      if (response.success && response.data != null) {
        _healthProfile = response.data;
        _lastFetchTime = DateTime.now();
        _errorMessage = null;

        // Cache the result
        await _storageService.setCacheData(
          _cacheKey,
          _healthProfile!.toJson(),
          ttl: _cacheDuration,
        );

        _setState(HealthProfileState.loaded);
        return true;
      } else {
        _setError(response.message ?? 'Failed to create health profile');
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    }
  }

  // Update health profile
  Future<bool> updateHealthProfile(HealthProfile profile) async {
    try {
      _setState(HealthProfileState.loading);

      final response = await _healthProfileService.updateHealthProfile(profile);

      if (response.success && response.data != null) {
        _healthProfile = response.data;
        _lastFetchTime = DateTime.now();
        _errorMessage = null;

        // Invalidate cache and update with new data
        await _storageService.removeValue(_cacheKey);
        await _storageService.setCacheData(
          _cacheKey,
          _healthProfile!.toJson(),
          ttl: _cacheDuration,
        );

        _setState(HealthProfileState.loaded);
        return true;
      } else {
        _setError(response.message ?? 'Failed to update health profile');
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    }
  }

  // Add chronic condition
  Future<bool> addChronicCondition(ChronicCondition condition) async {
    try {
      _setState(HealthProfileState.loading);

      final response = await _healthProfileService.addChronicCondition(condition);

      if (response.success) {
        // Invalidate cache and refresh profile
        await _storageService.removeValue(_cacheKey);
        await loadHealthProfile(forceRefresh: true);
        return true;
      } else {
        _setError(response.message ?? 'Failed to add chronic condition');
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    }
  }

  // Remove chronic condition
  Future<bool> removeChronicCondition(String conditionId) async {
    try {
      _setState(HealthProfileState.loading);

      final response =
          await _healthProfileService.removeChronicCondition(conditionId);

      if (response.success) {
        // Invalidate cache and refresh profile
        await _storageService.removeValue(_cacheKey);
        await loadHealthProfile(forceRefresh: true);
        return true;
      } else {
        _setError(response.message ?? 'Failed to remove chronic condition');
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    }
  }

  // Add allergy
  Future<bool> addAllergy(Allergy allergy) async {
    try {
      _setState(HealthProfileState.loading);

      final response = await _healthProfileService.addAllergy(allergy);

      if (response.success) {
        // Invalidate cache and refresh profile
        await _storageService.removeValue(_cacheKey);
        await loadHealthProfile(forceRefresh: true);
        return true;
      } else {
        _setError(response.message ?? 'Failed to add allergy');
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    }
  }

  // Remove allergy
  Future<bool> removeAllergy(String allergen) async {
    try {
      _setState(HealthProfileState.loading);

      final response = await _healthProfileService.removeAllergy(allergen);

      if (response.success) {
        // Invalidate cache and refresh profile
        await _storageService.removeValue(_cacheKey);
        await loadHealthProfile(forceRefresh: true);
        return true;
      } else {
        _setError(response.message ?? 'Failed to remove allergy');
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    }
  }

  // Update vitals
  Future<bool> updateVitals({
    double? height,
    double? weight,
    String? bloodType,
  }) async {
    try {
      _setState(HealthProfileState.loading);

      final response = await _healthProfileService.updateVitals(
        height: height,
        weight: weight,
        bloodType: bloodType,
      );

      if (response.success) {
        // Invalidate cache and refresh profile
        await _storageService.removeValue(_cacheKey);
        await loadHealthProfile(forceRefresh: true);
        return true;
      } else {
        _setError(response.message ?? 'Failed to update vitals');
        return false;
      }
    } catch (e) {
      _setError('An error occurred: $e');
      return false;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    await _storageService.removeValue(_cacheKey);
    _lastFetchTime = null;
  }
}
