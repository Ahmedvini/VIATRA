import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {

  const LoadingWidget({
    super.key,
    this.message,
    this.size = 40.0,
    this.color,
  });
  final String? message;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? theme.primaryColor,
              ),
              strokeWidth: 3.0,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            const SizedBox(height: 16),
            Text(
              'Please wait...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {

  const LoadingOverlay({
    required this.isLoading, required this.child, super.key,
    this.message,
  });
  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) => Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black54,
            child: LoadingWidget(message: message),
          ),
      ],
    );
}

class SmallLoadingIndicator extends StatelessWidget {

  const SmallLoadingIndicator({
    super.key,
    this.color,
  });
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).primaryColor,
        ),
        strokeWidth: 2.0,
      ),
    );
}
