import 'package:flutter/material.dart';

enum ButtonVariant {
  primary,
  secondary,
  outlined,
  text,
  danger,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final bool isIconLeading;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final TextStyle? textStyle;
  final double? elevation;
  final FocusNode? focusNode;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.isIconLeading = true,
    this.width,
    this.padding,
    this.borderRadius,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.textStyle,
    this.elevation,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final isEnabled = !isDisabled && !isLoading && onPressed != null;
    
    return SizedBox(
      width: width,
      height: _getHeight(),
      child: _buildButton(context, theme, colorScheme, isEnabled),
    );
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return 48;
      case ButtonSize.large:
        return 56;
    }
  }

  EdgeInsetsGeometry _getPadding() {
    if (padding != null) return padding!;
    
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    if (textStyle != null) return textStyle!;
    
    switch (size) {
      case ButtonSize.small:
        return theme.textTheme.bodyMedium!.copyWith(
          fontWeight: FontWeight.w600,
        );
      case ButtonSize.medium:
        return theme.textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w600,
        );
      case ButtonSize.large:
        return theme.textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.w600,
        );
    }
  }

  Widget _buildButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isEnabled,
  ) {
    Widget buttonChild = _buildButtonContent();

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          focusNode: focusNode,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.primary,
            foregroundColor: foregroundColor ?? colorScheme.onPrimary,
            disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
            disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
            elevation: elevation ?? 2,
            shadowColor: colorScheme.shadow,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            textStyle: _getTextStyle(theme),
          ),
          child: buttonChild,
        );

      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          focusNode: focusNode,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.secondary,
            foregroundColor: foregroundColor ?? colorScheme.onSecondary,
            disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
            disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
            elevation: elevation ?? 1,
            shadowColor: colorScheme.shadow,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            textStyle: _getTextStyle(theme),
          ),
          child: buttonChild,
        );

      case ButtonVariant.outlined:
        return OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          focusNode: focusNode,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? colorScheme.primary,
            disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
            padding: _getPadding(),
            side: BorderSide(
              color: borderColor ?? colorScheme.outline,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            textStyle: _getTextStyle(theme),
          ),
          child: buttonChild,
        );

      case ButtonVariant.text:
        return TextButton(
          onPressed: isEnabled ? onPressed : null,
          focusNode: focusNode,
          style: TextButton.styleFrom(
            foregroundColor: foregroundColor ?? colorScheme.primary,
            disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            textStyle: _getTextStyle(theme),
          ),
          child: buttonChild,
        );

      case ButtonVariant.danger:
        return ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          focusNode: focusNode,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? colorScheme.error,
            foregroundColor: foregroundColor ?? colorScheme.onError,
            disabledBackgroundColor: colorScheme.onSurface.withOpacity(0.12),
            disabledForegroundColor: colorScheme.onSurface.withOpacity(0.38),
            elevation: elevation ?? 2,
            shadowColor: colorScheme.shadow,
            padding: _getPadding(),
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius ?? BorderRadius.circular(8),
            ),
            textStyle: _getTextStyle(theme),
          ),
          child: buttonChild,
        );
    }
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == ButtonVariant.outlined || variant == ButtonVariant.text
                ? Theme.of(context as BuildContext).colorScheme.primary
                : Theme.of(context as BuildContext).colorScheme.onPrimary,
          ),
        ),
      );
    }

    if (icon != null) {
      final iconWidget = SizedBox(
        width: _getIconSize(),
        height: _getIconSize(),
        child: icon,
      );

      if (isIconLeading) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Text(text),
          ],
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text),
            const SizedBox(width: 8),
            iconWidget,
          ],
        );
      }
    }

    return Text(text);
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 20;
      case ButtonSize.large:
        return 24;
    }
  }
}

// Specialized button variants
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final ButtonSize size;
  final double? width;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.size = ButtonSize.medium,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.primary,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final ButtonSize size;
  final double? width;

  const SecondaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.size = ButtonSize.medium,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.secondary,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }
}

class OutlinedCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final ButtonSize size;
  final double? width;

  const OutlinedCustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.size = ButtonSize.medium,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.outlined,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }
}

class TextCustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final ButtonSize size;
  final double? width;

  const TextCustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.size = ButtonSize.medium,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.text,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final ButtonSize size;
  final double? width;

  const DangerButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.size = ButtonSize.medium,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      variant: ButtonVariant.danger,
      size: size,
      isLoading: isLoading,
      isDisabled: isDisabled,
      icon: icon,
      width: width,
    );
  }
}
