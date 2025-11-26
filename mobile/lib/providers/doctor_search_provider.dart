import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/doctor_model.dart';
import '../models/doctor_search_filter.dart';
import '../services/doctor_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

enum DoctorSearchState {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
}

class CachedSearchResult {
  final List<Doctor> doctors;
  final int totalPages;
  final int totalResults;
  final DateTime timestamp;

  CachedSearchResult({
    required this.doctors,
    required this.totalPages,
    required this.totalResults,
    required this.timestamp,
  });

  bool get isExpired {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    return diff.inMinutes >= DoctorSearchConstants.cacheExpirationMinutes;
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'doctors': doctors.map((d) => d.toJson()).toList(),
      'totalPages': totalPages,
      'totalResults': totalResults,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON from storage
  factory CachedSearchResult.fromJson(Map<String, dynamic> json) {
    return CachedSearchResult(
      doctors: (json['doctors'] as List<dynamic>)
          .map((d) => Doctor.fromJson(d as Map<String, dynamic>))
          .toList(),
      totalPages: json['totalPages'] as int,
      totalResults: json['totalResults'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class DoctorSearchProvider extends ChangeNotifier {
  final DoctorService _doctorService;
  final StorageService _storageService;

  DoctorSearchState _state = DoctorSearchState.initial;
  List<Doctor> _doctors = [];
  DoctorSearchFilter _filter = DoctorSearchFilter();
  int _currentPage = 1;
  int _totalPages = 0;
  int _totalResults = 0;
  String? _errorMessage;
  final Map<String, CachedSearchResult> _cachedResults = {};

  DoctorSearchProvider({
    required DoctorService doctorService,
    required StorageService storageService,
  })  : _doctorService = doctorService,
        _storageService = storageService {
    _loadFromStorage();
  }

  /// Load cached results from storage on initialization
  Future<void> _loadFromStorage() async {
    try {
      final cacheKey = _getCacheKey();
      final cachedJson = await _storageService.getCacheData('doctor_search_$cacheKey');
      
      if (cachedJson != null) {
        final cachedResult = CachedSearchResult.fromJson(cachedJson as Map<String, dynamic>);
        
        if (!cachedResult.isExpired) {
          _doctors = cachedResult.doctors;
          _totalPages = cachedResult.totalPages;
          _totalResults = cachedResult.totalResults;
          _state = DoctorSearchState.loaded;
          _currentPage = 1;
          
          // Also seed in-memory cache
          _cachedResults[cacheKey] = cachedResult;
          
          notifyListeners();
        }
      }
    } catch (e) {
      // Silently fail if storage loading fails
      debugPrint('Failed to load from storage: $e');
    }
  }

  // Getters
  DoctorSearchState get state => _state;
  List<Doctor> get doctors => _doctors;
  DoctorSearchFilter get filter => _filter;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalResults => _totalResults;
  String? get errorMessage => _errorMessage;
  
  bool get isLoading => _state == DoctorSearchState.loading;
  bool get hasResults => _doctors.isNotEmpty;
  bool get hasMore => _currentPage < _totalPages;
  bool get isLoadingMore => _state == DoctorSearchState.loadingMore;

  /// Generate cache key from filter
  String _getCacheKey() {
    return json.encode(_filter.toJson());
  }

  /// Check cache for results
  CachedSearchResult? _getCachedResults() {
    final key = _getCacheKey();
    final cached = _cachedResults[key];
    
    if (cached != null && !cached.isExpired) {
      return cached;
    }
    
    // Remove expired cache
    if (cached != null && cached.isExpired) {
      _cachedResults.remove(key);
    }
    
    return null;
  }

  /// Cache search results (in-memory and persistent storage)
  Future<void> _cacheResults(List<Doctor> doctors, int totalPages, int totalResults) async {
    final key = _getCacheKey();
    final cachedResult = CachedSearchResult(
      doctors: doctors,
      totalPages: totalPages,
      totalResults: totalResults,
      timestamp: DateTime.now(),
    );
    
    // Store in memory
    _cachedResults[key] = cachedResult;
    
    // Persist to storage with TTL
    try {
      await _storageService.setCacheData(
        'doctor_search_$key',
        cachedResult.toJson(),
        ttl: Duration(minutes: DoctorSearchConstants.cacheTTLMinutes),
      );
    } catch (e) {
      // Silently fail if storage fails, in-memory cache still works
      debugPrint('Failed to persist cache to storage: $e');
    }
  }

  /// Search doctors with current filter
  Future<void> searchDoctors() async {
    // Check cache first
    final cached = _getCachedResults();
    if (cached != null) {
      _doctors = cached.doctors;
      _totalPages = cached.totalPages;
      _totalResults = cached.totalResults;
      _currentPage = 1;
      _state = DoctorSearchState.loaded;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _state = DoctorSearchState.loading;
    _errorMessage = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final response = await _doctorService.searchDoctors(
        _filter,
        page: _currentPage,
        limit: DoctorSearchConstants.defaultPageSize,
      );

      if (response.success && response.data != null) {
        _doctors = response.data!.doctors;
        _totalPages = response.data!.pagination.totalPages;
        _totalResults = response.data!.pagination.total;
        _state = DoctorSearchState.loaded;
        
        // Cache results
        _cacheResults(_doctors, _totalPages, _totalResults);
      } else {
        _state = DoctorSearchState.error;
        _errorMessage = response.message ?? 'Failed to search doctors';
      }
    } catch (e) {
      _state = DoctorSearchState.error;
      _errorMessage = 'An error occurred: $e';
    }

    notifyListeners();
  }

  /// Load more doctors (pagination)
  Future<void> loadMoreDoctors() async {
    if (!hasMore || isLoadingMore) return;

    _state = DoctorSearchState.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _doctorService.searchDoctors(
        _filter,
        page: nextPage,
        limit: 20,
      );

      if (response.success && response.data != null) {
        _doctors.addAll(response.data!.doctors);
        _currentPage = nextPage;
        _state = DoctorSearchState.loaded;
      } else {
        _state = DoctorSearchState.error;
        _errorMessage = response.message ?? 'Failed to load more doctors';
      }
    } catch (e) {
      _state = DoctorSearchState.error;
      _errorMessage = 'An error occurred: $e';
    }

    notifyListeners();
  }

  /// Update filter and trigger search
  Future<void> updateFilter(DoctorSearchFilter newFilter) async {
    _filter = newFilter;
    _currentPage = 1;
    await searchDoctors();
  }

  /// Clear search and reset to initial state
  void clearSearch() {
    _state = DoctorSearchState.initial;
    _doctors = [];
    _filter = DoctorSearchFilter();
    _currentPage = 1;
    _totalPages = 0;
    _totalResults = 0;
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh search (bypass cache)
  Future<void> refreshSearch() async {
    // Clear cache for current filter
    final key = _getCacheKey();
    _cachedResults.remove(key);
    
    // Remove from persistent storage
    try {
      await _storageService.remove('cache_doctor_search_$key');
    } catch (e) {
      debugPrint('Failed to remove cache from storage: $e');
    }
    
    await searchDoctors();
  }

  /// Clear all cached results (memory and storage)
  Future<void> clearCache() async {
    _cachedResults.clear();
    
    // Clear all doctor search cache from storage
    try {
      final keys = await _storageService.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_doctor_search_')) {
          await _storageService.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Failed to clear cache from storage: $e');
    }
  }
}
