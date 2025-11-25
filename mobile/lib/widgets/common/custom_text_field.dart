import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final FocusNode? focusNode;
  final String? helperText;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final bool autofocus;
  final TextCapitalization textCapitalization;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.focusNode,
    this.helperText,
    this.fillColor,
    this.contentPadding,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.border,
    this.focusedBorder,
    this.enabledBorder,
    this.errorBorder,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = false;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChanged);
    }
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: widget.labelStyle ??
                theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onSaved: widget.onSaved,
          onTap: widget.onTap,
          obscureText: _obscureText,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          textCapitalization: widget.textCapitalization,
          style: widget.style ?? theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: widget.hintStyle ??
                theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
            helperText: widget.helperText,
            helperStyle: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: widget.fillColor ??
                (widget.enabled
                    ? colorScheme.surface
                    : colorScheme.surface.withOpacity(0.5)),
            contentPadding: widget.contentPadding ??
                const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
            border: widget.border ?? _getDefaultBorder(colorScheme),
            enabledBorder: widget.enabledBorder ?? _getDefaultBorder(colorScheme),
            focusedBorder: widget.focusedBorder ?? _getFocusedBorder(colorScheme),
            errorBorder: widget.errorBorder ?? _getErrorBorder(colorScheme),
            focusedErrorBorder: _getFocusedErrorBorder(colorScheme),
            counterText: '', // Hide character counter
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }

  InputBorder _getDefaultBorder(ColorScheme colorScheme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.outline.withOpacity(0.5),
        width: 1,
      ),
    );
  }

  InputBorder _getFocusedBorder(ColorScheme colorScheme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: 2,
      ),
    );
  }

  InputBorder _getErrorBorder(ColorScheme colorScheme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.error,
        width: 1,
      ),
    );
  }

  InputBorder _getFocusedErrorBorder(ColorScheme colorScheme) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.error,
        width: 2,
      ),
    );
  }
}

// Specialized text field variants
class EmailTextField extends StatelessWidget {
  final String? label;
  final String? initialValue;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final bool enabled;
  final FocusNode? focusNode;

  const EmailTextField({
    Key? key,
    this.label = 'Email',
    this.initialValue,
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: 'Enter your email address',
      initialValue: initialValue,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      enabled: enabled,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.email_outlined),
      textCapitalization: TextCapitalization.none,
    );
  }
}

class PasswordTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;

  const PasswordTextField({
    Key? key,
    this.label = 'Password',
    this.hint = 'Enter your password',
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
    this.focusNode,
    this.textInputAction = TextInputAction.done,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      enabled: enabled,
      focusNode: focusNode,
      obscureText: true,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      prefixIcon: const Icon(Icons.lock_outline),
    );
  }
}

class PhoneTextField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final bool enabled;
  final FocusNode? focusNode;

  const PhoneTextField({
    Key? key,
    this.label = 'Phone Number',
    this.controller,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.enabled = true,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: 'Enter your phone number',
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      enabled: enabled,
      focusNode: focusNode,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.phone_outlined),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[\d\s\-\(\)\+]')),
      ],
    );
  }
}

class SearchTextField extends StatelessWidget {
  final String? hint;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final void Function()? onClear;
  final bool enabled;
  final FocusNode? focusNode;

  const SearchTextField({
    Key? key,
    this.hint = 'Search...',
    this.controller,
    this.onChanged,
    this.onClear,
    this.enabled = true,
    this.focusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      focusNode: focusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: controller?.text.isNotEmpty == true
          ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                controller?.clear();
                onClear?.call();
              },
            )
          : null,
    );
  }
}
