import 'package:flutter/material.dart';

enum ErrorType {
  network,
  auth,
  validation,
  server,
  unknown,
}

class ErrorDisplayWidget extends StatelessWidget {

  const ErrorDisplayWidget({
    super.key,
    this.message,
    this.type = ErrorType.unknown,
    this.onRetry,
    this.icon,
    this.compact = false,
  });
  final String? message;
  final ErrorType type;
  final VoidCallback? onRetry;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final errorMessage = message ?? _getDefaultMessage(type);
    final errorIcon = icon ?? _getDefaultIcon(type);

    if (compact) {
      return _buildCompactError(context, errorMessage, errorIcon, theme);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              errorIcon,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompactError(
    BuildContext context,
    String errorMessage,
    IconData errorIcon,
    ThemeData theme,
  ) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            errorIcon,
            color: theme.colorScheme.error,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );

  String _getDefaultMessage(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return 'Network connection error. Please check your internet connection.';
      case ErrorType.auth:
        return 'Authentication error. Please log in again.';
      case ErrorType.validation:
        return 'Validation error. Please check your input.';
      case ErrorType.server:
        return 'Server error. Please try again later.';
      case ErrorType.unknown:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  IconData _getDefaultIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.auth:
        return Icons.lock_outline;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.server:
        return Icons.dns_outlined;
      case ErrorType.unknown:
        return Icons.warning_amber_outlined;
    }
  }
}

class ErrorSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    ErrorType type = ErrorType.unknown,
    VoidCallback? onRetry,
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _getIconForType(type),
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message),
            ),
          ],
        ),
        backgroundColor: theme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static IconData _getIconForType(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.auth:
        return Icons.lock_outline;
      case ErrorType.validation:
        return Icons.error_outline;
      case ErrorType.server:
        return Icons.dns_outlined;
      case ErrorType.unknown:
        return Icons.warning_amber_outlined;
    }
  }
}
