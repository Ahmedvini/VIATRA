import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Log levels
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Logger service for centralized logging
class Logger {
  static bool _initialized = false;
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Initialize logger
  static void init({LogLevel minLevel = LogLevel.info}) {
    _minLevel = minLevel;
    _initialized = true;
    info('Logger initialized with minimum level: ${minLevel.name}');
  }

  /// Log debug message
  static void debug(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.debug, message, null, context);
  }

  /// Log info message
  static void info(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.info, message, null, context);
  }

  /// Log warning message
  static void warning(String message, [Map<String, dynamic>? context]) {
    _log(LogLevel.warning, message, null, context);
  }

  /// Log error message
  static void error(String message, [StackTrace? stackTrace, Map<String, dynamic>? context]) {
    _log(LogLevel.error, message, stackTrace, context);
  }

  /// Internal logging method
  static void _log(
    LogLevel level,
    String message, [
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ]) {
    // Check if we should log this level
    if (level.index < _minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelName = level.name.toUpperCase();
    
    // Format the log message
    String logMessage = '[$timestamp] [$levelName] $message';
    
    // Add context if provided
    if (context != null && context.isNotEmpty) {
      logMessage += '\nContext: $context';
    }
    
    // Add stack trace for errors
    if (stackTrace != null) {
      logMessage += '\nStack Trace:\n$stackTrace';
    }

    // Output to appropriate destination based on environment
    if (kDebugMode) {
      // In debug mode, use developer.log for better formatting in IDE
      developer.log(
        message,
        name: 'Viatra',
        level: _getLevelValue(level),
        error: level == LogLevel.error ? 'ERROR' : null,
        stackTrace: stackTrace,
      );
      
      // Also print to console for immediate visibility
      debugPrint(logMessage);
    } else {
      // In release mode, just use print
      print(logMessage);
    }

    // TODO: Send logs to external service in production
    // _sendToExternalService(level, message, stackTrace, context);
  }

  /// Get numeric level value for developer.log
  static int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500; // FINE
      case LogLevel.info:
        return 800; // INFO
      case LogLevel.warning:
        return 900; // WARNING
      case LogLevel.error:
        return 1000; // SEVERE
    }
  }

  /// Convenience method for logging API requests
  static void apiRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
  }) {
    debug('API Request: $method $url', {
      'method': method,
      'url': url,
      'headers': headers,
      'body': body?.toString().length ?? 0,
    });
  }

  /// Convenience method for logging API responses
  static void apiResponse({
    required String method,
    required String url,
    required int statusCode,
    int? responseSize,
    Duration? duration,
  }) {
    final level = statusCode >= 400 ? LogLevel.error : LogLevel.info;
    final message = 'API Response: $method $url -> $statusCode';
    
    _log(level, message, null, {
      'method': method,
      'url': url,
      'statusCode': statusCode,
      'responseSize': responseSize,
      'duration': duration?.inMilliseconds,
    });
  }

  /// Log navigation events
  static void navigation(String from, String to) {
    debug('Navigation: $from -> $to', {
      'from': from,
      'to': to,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Log user actions
  static void userAction(String action, [Map<String, dynamic>? details]) {
    info('User Action: $action', {
      'action': action,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?details,
    });
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration, [Map<String, dynamic>? metrics]) {
    final level = duration.inMilliseconds > 1000 ? LogLevel.warning : LogLevel.info;
    _log(level, 'Performance: $operation took ${duration.inMilliseconds}ms', null, {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      ...?metrics,
    });
  }

  /// Log memory usage
  static void memory(String context, int usageBytes) {
    final usageMB = (usageBytes / (1024 * 1024)).toStringAsFixed(2);
    debug('Memory Usage: $context -> ${usageMB}MB', {
      'context': context,
      'usage_bytes': usageBytes,
      'usage_mb': usageMB,
    });
  }

  /// Log feature usage
  static void feature(String featureName, Map<String, dynamic> usage) {
    info('Feature Usage: $featureName', {
      'feature': featureName,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...usage,
    });
  }

  /// Log security events
  static void security(String event, [Map<String, dynamic>? details]) {
    warning('Security Event: $event', {
      'event': event,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?details,
    });
  }

  /// Log business events
  static void business(String event, Map<String, dynamic> data) {
    info('Business Event: $event', {
      'event': event,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...data,
    });
  }

  /// Measure and log execution time of a function
  static T measure<T>(String operation, T Function() function) {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = function();
      stopwatch.stop();
      performance(operation, stopwatch.elapsed);
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      error('Error during $operation: $e', stackTrace, {
        'operation': operation,
        'duration_ms': stopwatch.elapsedMilliseconds,
      });
      rethrow;
    }
  }

  /// Measure and log execution time of an async function
  static Future<T> measureAsync<T>(String operation, Future<T> Function() function) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      final result = await function();
      stopwatch.stop();
      performance(operation, stopwatch.elapsed);
      return result;
    } catch (e, stackTrace) {
      stopwatch.stop();
      error('Error during $operation: $e', stackTrace, {
        'operation': operation,
        'duration_ms': stopwatch.elapsedMilliseconds,
      });
      rethrow;
    }
  }

  /// Set minimum log level
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
    info('Log level changed to: ${level.name}');
  }

  /// Get current minimum log level
  static LogLevel get minLevel => _minLevel;

  /// Check if logger is initialized
  static bool get isInitialized => _initialized;

  /// Log application lifecycle events
  static void lifecycle(String event, [Map<String, dynamic>? details]) {
    info('App Lifecycle: $event', {
      'event': event,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?details,
    });
  }

  /// Log configuration changes
  static void config(String setting, dynamic oldValue, dynamic newValue) {
    info('Config Change: $setting', {
      'setting': setting,
      'old_value': oldValue?.toString(),
      'new_value': newValue?.toString(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Create a logger for a specific class or module
  static ModuleLogger module(String moduleName) {
    return ModuleLogger(moduleName);
  }

  // TODO: Implement external logging service integration
  // static void _sendToExternalService(
  //   LogLevel level,
  //   String message,
  //   StackTrace? stackTrace,
  //   Map<String, dynamic>? context,
  // ) {
  //   // Send to Firebase Analytics, Mixpanel, or other logging service
  // }
}

/// Module-specific logger for better organization
class ModuleLogger {
  final String _moduleName;

  ModuleLogger(this._moduleName);

  void debug(String message, [Map<String, dynamic>? context]) {
    Logger._log(LogLevel.debug, '[$_moduleName] $message', null, context);
  }

  void info(String message, [Map<String, dynamic>? context]) {
    Logger._log(LogLevel.info, '[$_moduleName] $message', null, context);
  }

  void warning(String message, [Map<String, dynamic>? context]) {
    Logger._log(LogLevel.warning, '[$_moduleName] $message', null, context);
  }

  void error(String message, [StackTrace? stackTrace, Map<String, dynamic>? context]) {
    Logger._log(LogLevel.error, '[$_moduleName] $message', stackTrace, context);
  }
}
