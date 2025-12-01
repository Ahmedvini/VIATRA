import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'logger.dart';

/// Global error handler for the application
class ErrorHandler {
  static BuildContext? _context;
  static bool _initialized = false;

  /// Initialize error handler with application context
  static void init(BuildContext context) {
    _context = context;
    _initialized = true;
  }

  /// Log error with context information
  static void logError(
    Object error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ]) {
    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('ERROR: $error');
      if (stackTrace != null) {
        debugPrint('STACK TRACE: $stackTrace');
      }
      if (context != null) {
        debugPrint('CONTEXT: $context');
      }
    }

    // Log using Logger service
    Logger.error('Application Error: $error', stackTrace, context);

    // TODO: Send to crash reporting service (Firebase Crashlytics, Sentry, etc.)
    // CrashlyticsService.recordError(error, stackTrace, context);
  }

  /// Handle and display user-friendly error messages
  static void handleError(
    Object error, [
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  ]) {
    // Log the error
    logError(error, stackTrace, context);

    // Show user-friendly message
    final userMessage = _getUserFriendlyMessage(error);
    
    if (_initialized && _context != null) {
      _showErrorToUser(userMessage);
    }
  }

  /// Convert technical errors to user-friendly messages
  static String _getUserFriendlyMessage(Object error) {
    final errorString = error.toString().toLowerCase();

    if (error is SocketException || errorString.contains('network') || 
        errorString.contains('connection') || errorString.contains('timeout') ||
        errorString.contains('socket')) {
      return 'Network connection error. Please check your internet connection and try again.';
    }

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Your session has expired. Please log in again.';
    }

    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'You don\'t have permission to perform this action.';
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'The requested resource was not found.';
    }

    if (errorString.contains('server error') || errorString.contains('500') ||
        errorString.contains('502') || errorString.contains('503')) {
      return 'Server error occurred. Please try again later.';
    }

    if (errorString.contains('validation') || errorString.contains('invalid')) {
      return 'Please check your input and try again.';
    }

    if (errorString.contains('storage') || errorString.contains('disk') ||
        errorString.contains('space')) {
      return 'Storage error occurred. Please free up some space and try again.';
    }

    // Generic error message
    return 'An unexpected error occurred. Please try again.';
  }

  /// Show error message to user
  static void _showErrorToUser(String message) {
    if (_context == null) return;

    // Try to show as SnackBar first
    try {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(_context!).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } catch (e) {
      // If SnackBar fails, try dialog
      try {
        showDialog(
          context: _context!,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        // If dialog also fails, just log it
        Logger.error('Failed to show error to user: $e');
      }
    }
  }

  /// Handle specific error types
  
  /// Handle network errors
  static void handleNetworkError([String? customMessage]) {
    final message = customMessage ?? 
        'Network connection error. Please check your internet connection and try again.';
    
    logError('Network Error: $message');
    
    if (_initialized && _context != null) {
      _showErrorToUser(message);
    }
  }

  /// Handle authentication errors
  static void handleAuthError([String? customMessage]) {
    final message = customMessage ?? 
        'Authentication failed. Please log in again.';
    
    logError('Authentication Error: $message');
    
    if (_initialized && _context != null) {
      _showErrorToUser(message);
      // TODO: Navigate to login screen
      // NavigationService().goLogin();
    }
  }

  /// Handle validation errors
  static void handleValidationError(Map<String, dynamic> validationErrors) {
    final message = 'Please correct the following errors:\n${validationErrors.entries
            .map((entry) => '• ${entry.key}: ${entry.value}')
            .join('\n')}';
    
    logError('Validation Error', null, validationErrors);
    
    if (_initialized && _context != null) {
      _showErrorToUser(message);
    }
  }

  /// Handle API errors
  static void handleApiError(int statusCode, String? message, [Map<String, dynamic>? details]) {
    final errorMessage = message ?? 'API Error (Status: $statusCode)';
    
    logError('API Error: $errorMessage', null, {
      'statusCode': statusCode,
      'message': message,
      'details': details,
    });
    
    String userMessage;
    switch (statusCode) {
      case 400:
        userMessage = 'Invalid request. Please check your input.';
        break;
      case 401:
        userMessage = 'Authentication required. Please log in.';
        break;
      case 403:
        userMessage = 'Access denied. You don\'t have permission for this action.';
        break;
      case 404:
        userMessage = 'Resource not found.';
        break;
      case 429:
        userMessage = 'Too many requests. Please wait a moment and try again.';
        break;
      case 500:
        userMessage = 'Server error. Please try again later.';
        break;
      default:
        userMessage = message ?? 'An error occurred. Please try again.';
    }
    
    if (_initialized && _context != null) {
      _showErrorToUser(userMessage);
    }
  }

  /// Handle file operation errors
  static void handleFileError(String operation, [String? details]) {
    final message = 'File $operation failed${details != null ? ': $details' : ''}';
    
    logError('File Error: $message');
    
    if (_initialized && _context != null) {
      _showErrorToUser('File operation failed. Please try again.');
    }
  }

  /// Handle permission errors
  static void handlePermissionError(String permission) {
    final message = 'Permission denied for $permission';
    
    logError('Permission Error: $message');
    
    if (_initialized && _context != null) {
      _showErrorToUser('Permission required. Please grant $permission permission in settings.');
    }
  }

  /// Show non-blocking error notification
  static void showErrorNotification(String message) {
    if (_initialized && _context != null) {
      _showErrorToUser(message);
    }
  }

  /// Clear any displayed error messages
  static void clearErrors() {
    if (_context != null) {
      try {
        ScaffoldMessenger.of(_context!).clearSnackBars();
      } catch (e) {
        Logger.error('Failed to clear error messages: $e');
      }
    }
  }

  /// Check if error handler is initialized
  static bool get isInitialized => _initialized;

  /// Get current context (for testing purposes)
  @visibleForTesting
  static BuildContext? get context => _context;
}
