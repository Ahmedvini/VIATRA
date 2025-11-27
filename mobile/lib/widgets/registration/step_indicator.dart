import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {

  const StepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
    this.indicatorRadius = 12,
    this.lineHeight = 2,
    this.showLabels = true,
    this.labelStyle,
    this.padding,
  }) : super(key: key);
  final int currentStep;
  final int totalSteps;
  final List<String>? stepLabels;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;
  final double? indicatorRadius;
  final double? lineHeight;
  final bool showLabels;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final activeCol = activeColor ?? colorScheme.primary;
    final inactiveCol = inactiveColor ?? colorScheme.outline;
    final completedCol = completedColor ?? colorScheme.primary;

    return Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step indicators
          Row(
            children: List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final isActive = stepNumber == currentStep;
              final isCompleted = stepNumber < currentStep;
              final isLast = index == totalSteps - 1;

              return Expanded(
                child: Row(
                  children: [
                    // Step circle
                    Container(
                      width: indicatorRadius! * 2,
                      height: indicatorRadius! * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? completedCol
                            : isActive
                                ? activeCol
                                : inactiveCol.withOpacity(0.3),
                        border: Border.all(
                          color: isCompleted || isActive
                              ? Colors.transparent
                              : inactiveCol,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: colorScheme.onPrimary,
                                size: indicatorRadius,
                              )
                            : Text(
                                stepNumber.toString(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: isActive
                                      ? colorScheme.onPrimary
                                      : isCompleted
                                          ? colorScheme.onPrimary
                                          : inactiveCol,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    
                    // Connecting line (except for last step)
                    if (!isLast)
                      Expanded(
                        child: Container(
                          height: lineHeight,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? completedCol
                                : inactiveCol.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(lineHeight! / 2),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          
          // Step labels
          if (showLabels && stepLabels != null) ...[
            const SizedBox(height: 12),
            Row(
              children: List.generate(totalSteps, (index) {
                final stepNumber = index + 1;
                final isActive = stepNumber == currentStep;
                final isCompleted = stepNumber < currentStep;
                final label = stepLabels![index];

                return Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: labelStyle ??
                        theme.textTheme.bodySmall?.copyWith(
                          color: isCompleted || isActive
                              ? activeCol
                              : inactiveCol,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        ),
                  ),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

// Linear progress indicator variant
class LinearStepIndicator extends StatelessWidget {

  const LinearStepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.title,
    this.subtitle,
    this.progressColor,
    this.backgroundColor,
    this.height = 8,
    this.borderRadius,
    this.padding,
  }) : super(key: key);
  final int currentStep;
  final int totalSteps;
  final String? title;
  final String? subtitle;
  final Color? progressColor;
  final Color? backgroundColor;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final progress = currentStep / totalSteps;

    return Padding(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || subtitle != null) ...[
            if (title != null)
              Text(
                title!,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
          
          // Progress bar
          Container(
            height: height,
            decoration: BoxDecoration(
              color: backgroundColor ?? colorScheme.outline.withOpacity(0.2),
              borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
            ),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: height,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: backgroundColor ?? colorScheme.outline.withOpacity(0.2),
                    borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: height,
                  width: MediaQuery.of(context).size.width * progress,
                  decoration: BoxDecoration(
                    color: progressColor ?? colorScheme.primary,
                    borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
                  ),
                ),
              ],
            ),
          ),
          
          // Step counter
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $currentStep of $totalSteps',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Minimal step indicator for compact spaces
class MinimalStepIndicator extends StatelessWidget {

  const MinimalStepIndicator({
    Key? key,
    required this.currentStep,
    required this.totalSteps,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 8,
    this.spacing = 8,
    this.padding,
  }) : super(key: key);
  final int currentStep;
  final int totalSteps;
  final Color? activeColor;
  final Color? inactiveColor;
  final double dotSize;
  final double spacing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(totalSteps, (index) {
          final stepNumber = index + 1;
          final isActive = stepNumber <= currentStep;

          return Container(
            margin: EdgeInsets.symmetric(horizontal: spacing / 2),
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? (activeColor ?? colorScheme.primary)
                  : (inactiveColor ?? colorScheme.outline.withOpacity(0.3)),
            ),
          );
        }),
      ),
    );
  }
}
