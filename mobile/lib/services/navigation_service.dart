import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigation service for centralized navigation management
class NavigationService {
  factory NavigationService() => _instance;
  NavigationService._internal();
  static final NavigationService _instance = NavigationService._internal();

  /// Global navigator key for accessing navigation context
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Get current context
  BuildContext? get currentContext => navigatorKey.currentContext;

  /// Get current route name
  String? get currentRouteName {
    final context = currentContext;
    if (context != null) {
      return GoRouterState.of(context).name;
    }
    return null;
  }

  /// Get current route path
  String? get currentRoutePath {
    final context = currentContext;
    if (context != null) {
      return GoRouterState.of(context).uri.path;
    }
    return null;
  }

  // Navigation methods using GoRouter

  /// Navigate to a route
  void go(String path) {
    final context = currentContext;
    if (context != null) {
      context.go(path);
    }
  }

  /// Navigate to a named route
  void goNamed(String name, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters}) {
    final context = currentContext;
    if (context != null) {
      context.goNamed(name, pathParameters: pathParameters ?? {}, queryParameters: queryParameters);
    }
  }

  /// Push a route
  void push(String path) {
    final context = currentContext;
    if (context != null) {
      context.push(path);
    }
  }

  /// Push a named route
  void pushNamed(String name, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters}) {
    final context = currentContext;
    if (context != null) {
      context.pushNamed(name, pathParameters: pathParameters ?? {}, queryParameters: queryParameters);
    }
  }

  /// Pop current route
  void pop([dynamic result]) {
    final context = currentContext;
    if (context != null) {
      context.pop(result);
    }
  }

  /// Replace current route
  void pushReplacement(String path) {
    final context = currentContext;
    if (context != null) {
      context.pushReplacement(path);
    }
  }

  /// Replace current route with named route
  void pushReplacementNamed(String name, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters}) {
    final context = currentContext;
    if (context != null) {
      context.pushReplacementNamed(name, pathParameters: pathParameters ?? {}, queryParameters: queryParameters);
    }
  }

  /// Check if can pop
  bool canPop() {
    final context = currentContext;
    if (context != null) {
      return context.canPop();
    }
    return false;
  }

  // Convenience navigation methods

  /// Navigate to home
  void goHome() {
    go('/home');
  }

  /// Navigate to login
  void goLogin() {
    go('/auth/login');
  }

  /// Navigate to register
  void goRegister() {
    go('/auth/register');
  }

  /// Navigate to profile
  void goProfile() {
    go('/profile');
  }

  /// Navigate to settings
  void goSettings() {
    go('/settings');
  }

  /// Navigate to splash
  void goSplash() {
    go('/');
  }

  // Dialog and modal methods

  /// Show alert dialog
  Future<T?> showAlert<T>({
    required String title,
    required String message,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) async {
    final context = currentContext;
    if (context == null) return null;

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: actions ?? [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog
  Future<bool?> showConfirmation({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final context = currentContext;
    if (context == null) return null;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Show loading dialog
  Future<void> showLoading({String? message}) async {
    final context = currentContext;
    if (context == null) return;

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message ?? 'Loading...'),
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  void hideLoading() {
    final context = currentContext;
    if (context != null && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  /// Show snackbar
  void showSnackBar({
    required String message,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    final context = currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show error snackbar
  void showError(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.red,
    );
  }

  /// Show success snackbar
  void showSuccess(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.green,
    );
  }

  /// Show warning snackbar
  void showWarning(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.orange,
    );
  }

  /// Show info snackbar
  void showInfo(String message) {
    showSnackBar(
      message: message,
      backgroundColor: Colors.blue,
    );
  }

  /// Show bottom sheet
  Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isScrollControlled = false,
    bool isDismissible = true,
  }) async {
    final context = currentContext;
    if (context == null) return null;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      builder: (context) => child,
    );
  }

  /// Clear navigation stack and go to route
  void clearStackAndGo(String path) {
    final context = currentContext;
    if (context != null) {
      while (context.canPop()) {
        context.pop();
      }
      context.go(path);
    }
  }

  /// Clear navigation stack and go to named route
  void clearStackAndGoNamed(String name, {Map<String, String>? pathParameters, Map<String, dynamic>? queryParameters}) {
    final context = currentContext;
    if (context != null) {
      while (context.canPop()) {
        context.pop();
      }
      context.goNamed(name, pathParameters: pathParameters ?? {}, queryParameters: queryParameters);
    }
  }
}
