import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../services/storage_service.dart';

enum AppointmentState {
  initial,
  loading,
  loaded,
  error,
  loadingMore,
}

class CachedAppointmentResult {
  final List<Appointment> appointments;
  final int totalPages;
  final int totalResults;
  final DateTime timestamp;

  CachedAppointmentResult({
    required this.appointments,
    required this.totalPages,
    required this.totalResults,
    required this.timestamp,
  });

  bool get isExpired {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    return diff.inMinutes >= 5;
  }

  Map<String, dynamic> toJson() {
    return {
      'appointments': appointments.map((a) => a.toJson()).toList(),
      'totalPages': totalPages,
      'totalResults': totalResults,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CachedAppointmentResult.fromJson(Map<String, dynamic> json) {
    return CachedAppointmentResult(
      appointments: (json['appointments'] as List<dynamic>)
          .map((a) => Appointment.fromJson(a as Map<String, dynamic>))
          .toList(),
      totalPages: json['totalPages'] as int,
      totalResults: json['totalResults'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class AppointmentProvider extends ChangeNotifier {
  final AppointmentService _appointmentService;
  final StorageService _storageService;

  AppointmentState _state = AppointmentState.initial;
  List<Appointment> _appointments = [];
  Appointment? _currentAppointment;
  String? _errorMessage;
  int _currentPage = 1;
  int _totalPages = 0;
  int _totalResults = 0;
  String? _filterStatus;
  final Map<String, CachedAppointmentResult> _cachedResults = {};

  AppointmentProvider({
    required AppointmentService appointmentService,
    required StorageService storageService,
  })  : _appointmentService = appointmentService,
        _storageService = storageService {
    _loadFromStorage();
  }

  // Getters
  AppointmentState get state => _state;
  List<Appointment> get appointments => _appointments;
  Appointment? get currentAppointment => _currentAppointment;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage; // Alias for screen compatibility
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalResults => _totalResults;
  bool get isLoading => _state == AppointmentState.loading;
  bool get hasError => _state == AppointmentState.error;
  bool get hasMore => _currentPage < _totalPages;
  bool get hasMoreAppointments => hasMore; // Alias for screen compatibility
  bool get isLoadingMore => _state == AppointmentState.loadingMore;

  // Time slot state
  List<TimeSlot> _availableSlots = [];
  List<TimeSlot> get availableSlots => _availableSlots;

  List<Appointment> get upcomingAppointments {
    return _appointments.where((a) => a.isUpcoming).toList();
  }

  List<Appointment> get pastAppointments {
    return _appointments.where((a) => a.isPast).toList();
  }

  int get upcomingCount => upcomingAppointments.length;
  int get pastCount => pastAppointments.length;

  /// Generate cache key
  String _getCacheKey({String? status}) {
    return json.encode({'status': status});
  }

  /// Load cached results from storage
  Future<void> _loadFromStorage() async {
    try {
      final cacheKey = _getCacheKey(status: _filterStatus);
      final cachedJson = await _storageService.getCacheData('appointments_$cacheKey');

      if (cachedJson != null) {
        final cachedResult = CachedAppointmentResult.fromJson(cachedJson as Map<String, dynamic>);

        if (!cachedResult.isExpired) {
          _appointments = cachedResult.appointments;
          _totalPages = cachedResult.totalPages;
          _totalResults = cachedResult.totalResults;
          _state = AppointmentState.loaded;
          _currentPage = 1;

          // Seed in-memory cache
          _cachedResults[cacheKey] = cachedResult;

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Failed to load appointments from storage: $e');
    }
  }

  /// Check cache for results
  CachedAppointmentResult? _getCachedResults({String? status}) {
    final key = _getCacheKey(status: status);
    final cached = _cachedResults[key];

    if (cached != null && !cached.isExpired) {
      return cached;
    }

    if (cached != null && cached.isExpired) {
      _cachedResults.remove(key);
    }

    return null;
  }

  /// Cache appointment results
  Future<void> _cacheResults(
    List<Appointment> appointments,
    int totalPages,
    int totalResults, {
    String? status,
  }) async {
    final key = _getCacheKey(status: status);
    final cachedResult = CachedAppointmentResult(
      appointments: appointments,
      totalPages: totalPages,
      totalResults: totalResults,
      timestamp: DateTime.now(),
    );

    // Store in memory
    _cachedResults[key] = cachedResult;

    // Persist to storage
    try {
      await _storageService.setCacheData(
        'appointments_$key',
        cachedResult.toJson(),
        ttl: const Duration(minutes: 5),
      );
    } catch (e) {
      debugPrint('Failed to persist appointments cache: $e');
    }
  }

  /// Load appointments
  Future<void> loadMyAppointments({String? status, bool refresh = false}) async {
    // Check cache first if not refreshing
    if (!refresh) {
      final cached = _getCachedResults(status: status);
      if (cached != null) {
        _appointments = cached.appointments;
        _totalPages = cached.totalPages;
        _totalResults = cached.totalResults;
        _currentPage = 1;
        _filterStatus = status;
        _state = AppointmentState.loaded;
        _errorMessage = null;
        notifyListeners();
        return;
      }
    }

    _state = AppointmentState.loading;
    _errorMessage = null;
    _filterStatus = status;
    _currentPage = 1;
    notifyListeners();

    try {
      final response = await _appointmentService.getMyAppointments(
        status: status,
        page: _currentPage,
        limit: 20,
      );

      if (response.success && response.data != null) {
        _appointments = response.data!.appointments;
        _totalPages = response.data!.pagination.totalPages;
        _totalResults = response.data!.pagination.total;
        _state = AppointmentState.loaded;

        // Cache results
        await _cacheResults(_appointments, _totalPages, _totalResults, status: status);
      } else {
        _state = AppointmentState.error;
        _errorMessage = response.message ?? 'Failed to load appointments';
      }
    } catch (e) {
      _state = AppointmentState.error;
      _errorMessage = 'An error occurred: $e';
    }

    notifyListeners();
  }

  /// Load more appointments (pagination)
  Future<void> loadMoreAppointments() async {
    if (!hasMore || isLoadingMore) return;

    _state = AppointmentState.loadingMore;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _appointmentService.getMyAppointments(
        status: _filterStatus,
        page: nextPage,
        limit: 20,
      );

      if (response.success && response.data != null) {
        _appointments.addAll(response.data!.appointments);
        _currentPage = nextPage;
        _state = AppointmentState.loaded;
      } else {
        _state = AppointmentState.error;
        _errorMessage = response.message ?? 'Failed to load more appointments';
      }
    } catch (e) {
      _state = AppointmentState.error;
      _errorMessage = 'An error occurred: $e';
    }

    notifyListeners();
  }

  /// Load appointment by ID
  Future<void> loadAppointmentById(String appointmentId) async {
    _state = AppointmentState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _appointmentService.getAppointmentById(appointmentId);

      if (response.success && response.data != null) {
        _currentAppointment = response.data;
        _state = AppointmentState.loaded;
      } else {
        _state = AppointmentState.error;
        _errorMessage = response.message ?? 'Failed to load appointment';
      }
    } catch (e) {
      _state = AppointmentState.error;
      _errorMessage = 'An error occurred: $e';
    }

    notifyListeners();
  }

  /// Create appointment
  Future<Appointment?> createAppointment(
    String doctorId,
    Map<String, dynamic> appointmentData,
  ) async {
    try {
      final response = await _appointmentService.createAppointment(
        doctorId,
        appointmentData,
      );

      if (response.success && response.data != null) {
        // Invalidate cache and reload
        await clearCache();
        await loadMyAppointments();
        return response.data;
      } else {
        _errorMessage = response.message ?? 'Failed to create appointment';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      notifyListeners();
      return null;
    }
  }

  /// Update appointment
  Future<bool> updateAppointment(
    String appointmentId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      final response = await _appointmentService.updateAppointment(
        appointmentId,
        updateData,
      );

      if (response.success && response.data != null) {
        // Update local data
        final index = _appointments.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          _appointments[index] = response.data!;
        }
        if (_currentAppointment?.id == appointmentId) {
          _currentAppointment = response.data;
        }

        // Invalidate cache
        await clearCache();
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to update appointment';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  /// Cancel appointment
  Future<bool> cancelAppointment(String appointmentId, String reason) async {
    try {
      final response = await _appointmentService.cancelAppointment(
        appointmentId,
        reason,
      );

      if (response.success) {
        // Update local status
        final index = _appointments.indexWhere((a) => a.id == appointmentId);
        if (index != -1) {
          _appointments[index] = _appointments[index].copyWith(
            status: 'cancelled',
            cancellationReason: reason,
            cancelledAt: DateTime.now(),
          );
        }

        // Invalidate cache
        await clearCache();
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message ?? 'Failed to cancel appointment';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  /// Clear all caches
  Future<void> clearCache() async {
    _cachedResults.clear();

    try {
      final keys = await _storageService.getKeys();
      for (final key in keys) {
        if (key.startsWith('cache_appointments_')) {
          await _storageService.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Failed to clear appointments cache: $e');
    }
  }

  // Alias methods for screen compatibility
  Future<void> fetchAppointments({String? status, bool forceRefresh = false, bool loadMore = false}) async {
    if (loadMore) {
      await loadMoreAppointments();
    } else {
      await loadMyAppointments(status: status, refresh: forceRefresh);
    }
  }

  Future<Appointment?> fetchAppointmentById(String appointmentId) async {
    await loadAppointmentById(appointmentId);
    return _currentAppointment;
  }

  /// Fetch available time slots for a doctor
  Future<void> fetchAvailableSlots(String doctorId, DateTime date, {int duration = 30}) async {
    try {
      _state = AppointmentState.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await _appointmentService.getDoctorAvailability(
        doctorId,
        date,
        duration,
      );

      if (response.success && response.data != null) {
        _availableSlots = response.data!;
        _state = AppointmentState.loaded;
      } else {
        _state = AppointmentState.error;
        _errorMessage = response.message ?? 'Failed to load available slots';
        _availableSlots = [];
      }
    } catch (e) {
      _state = AppointmentState.error;
      _errorMessage = 'An error occurred: $e';
      _availableSlots = [];
    }

    notifyListeners();
  }

  /// Book an appointment (alias for createAppointment with named parameters)
  Future<Appointment> bookAppointment({
    required String doctorId,
    required String appointmentType,
    required DateTime scheduledStart,
    required DateTime scheduledEnd,
    required String reasonForVisit,
    String? chiefComplaint,
    bool urgent = false,
  }) async {
    final appointmentData = {
      'appointmentType': appointmentType,
      'scheduledStart': scheduledStart.toIso8601String(),
      'scheduledEnd': scheduledEnd.toIso8601String(),
      'reasonForVisit': reasonForVisit,
      if (chiefComplaint != null) 'chiefComplaint': chiefComplaint,
      'urgent': urgent,
    };

    final appointment = await createAppointment(doctorId, appointmentData);
    if (appointment == null) {
      throw Exception(_errorMessage ?? 'Failed to book appointment');
    }
    return appointment;
  }
}
