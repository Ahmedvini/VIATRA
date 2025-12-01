import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/storage_service.dart';
import '../utils/logger.dart';

class AppConfig {
  static late PackageInfo _packageInfo;
  static bool _initialized = false;
  
  // App Information
  static String get appName => _packageInfo.appName;
  static String get packageName => _packageInfo.packageName;
  static String get version => _packageInfo.version;
  static String get buildNumber => _packageInfo.buildNumber;
  
  // Environment
  static String get environment => dotenv.env['ENVIRONMENT'] ?? 'development';
  static bool get isProduction => environment == 'production';
  static bool get isDevelopment => environment == 'development';
  static bool get isStaging => environment == 'staging';
  static bool get isDebugMode => kDebugMode;
  
  // API Configuration
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1';
  static String get wsBaseUrl => dotenv.env['WS_BASE_URL'] ?? 'ws://localhost:8080';
  
  // Features
  static bool get enableLogging => _parseBool('ENABLE_LOGGING', true);
  static bool get enableCrashlytics => _parseBool('ENABLE_CRASHLYTICS', isProduction);
  static bool get enableAnalytics => _parseBool('ENABLE_ANALYTICS', isProduction);
  
  // Third-party Services
  static String get googleMapsApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  
  // Social Authentication
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  static String get appleClientId => dotenv.env['APPLE_CLIENT_ID'] ?? '';
  static String get facebookAppId => dotenv.env['FACEBOOK_APP_ID'] ?? '';
  
  // Push Notifications
  static String get fcmSenderId => dotenv.env['FCM_SENDER_ID'] ?? '';
  static String get apnsTeamId => dotenv.env['APNS_TEAM_ID'] ?? '';
  
  // Deep Links
  static String get customUrlScheme => dotenv.env['CUSTOM_URL_SCHEME'] ?? 'viatra';
  static String get universalLinkDomain => dotenv.env['UNIVERSAL_LINK_DOMAIN'] ?? 'viatra.health';
  
  // File Upload
  static int get maxFileSizeMB => _parseInt('MAX_FILE_SIZE_MB', 10);
  static List<String> get allowedImageTypes => 
      (dotenv.env['ALLOWED_IMAGE_TYPES'] ?? 'jpg,jpeg,png,gif').split(',');
  static List<String> get allowedDocumentTypes => 
      (dotenv.env['ALLOWED_DOCUMENT_TYPES'] ?? 'pdf,doc,docx').split(',');
  
  // Cache Configuration
  static int get cacheDurationMinutes => _parseInt('CACHE_DURATION_MINUTES', 30);
  static int get maxCacheSizeMB => _parseInt('MAX_CACHE_SIZE_MB', 100);
  
  // Security
  static bool get certificatePinningEnabled => _parseBool('CERTIFICATE_PINNING_ENABLED', isProduction);
  static bool get rootDetectionEnabled => _parseBool('ROOT_DETECTION_ENABLED', isProduction);
  static bool get debugModeDetectionEnabled => _parseBool('DEBUG_MODE_DETECTION_ENABLED', true);
  
  // Localization
  static String get defaultLocale => dotenv.env['DEFAULT_LOCALE'] ?? 'en';
  static List<String> get supportedLocales => 
      (dotenv.env['SUPPORTED_LOCALES'] ?? 'en,ar').split(',');
  
  // UI Configuration
  static String get themeMode => dotenv.env['THEME_MODE'] ?? 'system';
  static int get primaryColor => _parseColor('PRIMARY_COLOR', 0xFF2196F3);
  static int get accentColor => _parseColor('ACCENT_COLOR', 0xFF03DAC6);
  
  // Development Settings
  static bool get mockApiEnabled => _parseBool('MOCK_API_ENABLED', false);
  static bool get slowAnimations => _parseBool('SLOW_ANIMATIONS', false);
  static bool get showPerformanceOverlay => _parseBool('SHOW_PERFORMANCE_OVERLAY', false);
  
  /// Initialize the app configuration
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Load package info
      _packageInfo = await PackageInfo.fromPlatform();
      
      // Initialize storage
      await StorageService().initialize();
      
      _initialized = true;
      Logger.info('AppConfig initialized successfully');
      Logger.info('App: $appName v$version ($buildNumber)');
      Logger.info('Environment: $environment');
      Logger.info('API Base URL: $apiBaseUrl');
    } catch (e) {
      Logger.error('Failed to initialize AppConfig: $e');
      rethrow;
    }
  }
  
  /// Parse boolean from environment variable
  static bool _parseBool(String key, bool defaultValue) {
    final value = dotenv.env[key]?.toLowerCase();
    if (value == null) return defaultValue;
    return value == 'true' || value == '1';
  }
  
  /// Parse integer from environment variable
  static int _parseInt(String key, int defaultValue) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    return int.tryParse(value) ?? defaultValue;
  }
  
  /// Parse color from environment variable
  static int _parseColor(String key, int defaultValue) {
    final value = dotenv.env[key];
    if (value == null) return defaultValue;
    
    // Remove 0x prefix if present and parse as hex
    final cleanValue = value.replaceFirst('0x', '').replaceFirst('#', '');
    return int.tryParse('0x$cleanValue') ?? defaultValue;
  }
  
  /// Get configuration as a map for debugging
  static Map<String, dynamic> toMap() => {
      'appName': appName,
      'version': version,
      'buildNumber': buildNumber,
      'environment': environment,
      'apiBaseUrl': apiBaseUrl,
      'isDebugMode': isDebugMode,
      'enableLogging': enableLogging,
      'enableCrashlytics': enableCrashlytics,
      'enableAnalytics': enableAnalytics,
      'defaultLocale': defaultLocale,
      'supportedLocales': supportedLocales,
      'themeMode': themeMode,
    };
  
  /// Validate configuration
  static List<String> validate() {
    final errors = <String>[];
    
    if (apiBaseUrl.isEmpty) {
      errors.add('API_BASE_URL is required');
    }
    
    if (isProduction) {
      if (firebaseApiKey.isEmpty) {
        errors.add('FIREBASE_API_KEY is required in production');
      }
      if (googleMapsApiKey.isEmpty) {
        errors.add('GOOGLE_MAPS_API_KEY is required in production');
      }
    }
    
    return errors;
  }
}
