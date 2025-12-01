import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatefulWidget {

  const CustomDropdown({
    super.key,
    this.label,
    this.hint,
    this.value,
    required this.items,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.enabled = true,
    this.isExpanded = true,
    this.prefixIcon,
    this.fillColor,
    this.contentPadding,
    this.style,
    this.labelStyle,
    this.hintStyle,
    this.border,
    this.focusedBorder,
    this.enabledBorder,
    this.errorBorder,
    this.dropdownMaxHeight,
    this.searchable = false,
    this.searchHint,
    this.focusNode,
  });
  final String? label;
  final String? hint;
  final T? value;
  final List<DropdownItem<T>> items;
  final void Function(T?)? onChanged;
  final void Function(T?)? onSaved;
  final String? Function(T?)? validator;
  final bool enabled;
  final bool isExpanded;
  final Widget? prefixIcon;
  final Color? fillColor;
  final EdgeInsetsGeometry? contentPadding;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final InputBorder? border;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final InputBorder? errorBorder;
  final double? dropdownMaxHeight;
  final bool searchable;
  final String? searchHint;
  final FocusNode? focusNode;

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  List<DropdownItem<T>> _filteredItems = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChanged);
    _filteredItems = List.from(widget.items);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_onFocusChanged);
    }
    _searchController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        _filteredItems = widget.items
            .where((item) =>
                item.text.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
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
        if (widget.searchable) _buildSearchableDropdown(theme, colorScheme) else _buildRegularDropdown(theme, colorScheme),
      ],
    );
  }

  Widget _buildRegularDropdown(ThemeData theme, ColorScheme colorScheme) => DropdownButtonFormField<T>(
      initialValue: widget.value,
      items: widget.items.map((item) => DropdownMenuItem<T>(
          value: item.value,
          enabled: item.enabled,
          child: Row(
            children: [
              if (item.icon != null) ...[
                item.icon!,
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  item.text,
                  style: widget.style ?? theme.textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )).toList(),
      onChanged: widget.enabled ? widget.onChanged : null,
      onSaved: widget.onSaved,
      validator: widget.validator,
      focusNode: _focusNode,
      isExpanded: widget.isExpanded,
      style: widget.style ?? theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: widget.hintStyle ??
            theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
        prefixIcon: widget.prefixIcon,
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
      ),
      menuMaxHeight: widget.dropdownMaxHeight ?? 300,
    );

  Widget _buildSearchableDropdown(ThemeData theme, ColorScheme colorScheme) => Column(
      children: [
        GestureDetector(
          onTap: widget.enabled ? _showSearchableDropdown : null,
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: widget.hintStyle ??
                  theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
              prefixIcon: widget.prefixIcon,
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: widget.enabled
                    ? colorScheme.onSurface.withOpacity(0.6)
                    : colorScheme.onSurface.withOpacity(0.3),
              ),
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
            ),
            child: Text(
              _getSelectedText() ?? widget.hint ?? '',
              style: _getSelectedText() != null
                  ? (widget.style ?? theme.textTheme.bodyLarge)
                  : (widget.hintStyle ??
                      theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      )),
            ),
          ),
        ),
      ],
    );

  String? _getSelectedText() {
    if (widget.value == null) return null;
    final selectedItem = widget.items
        .where((item) => item.value == widget.value)
        .firstOrNull;
    return selectedItem?.text;
  }

  void _showSearchableDropdown() {
    _searchController.clear();
    _filteredItems = List.from(widget.items);
    
    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
              title: widget.label != null ? Text(widget.label!) : null,
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: widget.searchHint ?? 'Search...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _onSearchChanged(value);
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _filteredItems.isEmpty
                          ? const Center(
                              child: Text('No items found'),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: _filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = _filteredItems[index];
                                final isSelected = item.value == widget.value;
                                
                                return ListTile(
                                  leading: item.icon,
                                  title: Text(item.text),
                                  selected: isSelected,
                                  enabled: item.enabled,
                                  onTap: item.enabled
                                      ? () {
                                          widget.onChanged?.call(item.value);
                                          Navigator.pop(context);
                                        }
                                      : null,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
        ),
    );
  }

  InputBorder _getDefaultBorder(ColorScheme colorScheme) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.outline.withOpacity(0.5),
        width: 1,
      ),
    );

  InputBorder _getFocusedBorder(ColorScheme colorScheme) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.primary,
        width: 2,
      ),
    );

  InputBorder _getErrorBorder(ColorScheme colorScheme) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.error,
        width: 1,
      ),
    );

  InputBorder _getFocusedErrorBorder(ColorScheme colorScheme) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: colorScheme.error,
        width: 2,
      ),
    );
}

class DropdownItem<T> {

  const DropdownItem({
    required this.value,
    required this.text,
    this.icon,
    this.enabled = true,
  });
  final T value;
  final String text;
  final Widget? icon;
  final bool enabled;
}

// Extension for convenience
extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

// Specialized dropdown variants
class CountryDropdown extends StatelessWidget {

  const CountryDropdown({
    super.key,
    this.label = 'Country',
    this.value,
    required this.countries,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.enabled = true,
  });
  final String? label;
  final String? value;
  final List<String> countries;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) => CustomDropdown<String>(
      label: label,
      hint: 'Select country',
      value: value,
      items: countries
          .map((country) => DropdownItem(
                value: country,
                text: country,
                icon: const Icon(Icons.flag, size: 20),
              ))
          .toList(),
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      enabled: enabled,
      searchable: true,
      searchHint: 'Search countries...',
      prefixIcon: const Icon(Icons.public),
    );
}

class SpecializationDropdown extends StatelessWidget {

  const SpecializationDropdown({
    super.key,
    this.label = 'Specialization',
    this.value,
    required this.specializations,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.enabled = true,
  });
  final String? label;
  final String? value;
  final List<String> specializations;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) => CustomDropdown<String>(
      label: label,
      hint: 'Select specialization',
      value: value,
      items: specializations
          .map((specialization) => DropdownItem(
                value: specialization,
                text: specialization,
                icon: const Icon(Icons.medical_services, size: 20),
              ))
          .toList(),
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      enabled: enabled,
      searchable: true,
      searchHint: 'Search specializations...',
      prefixIcon: const Icon(Icons.medical_services),
    );
}

class BloodTypeDropdown extends StatelessWidget {

  const BloodTypeDropdown({
    super.key,
    this.label = 'Blood Type',
    this.value,
    required this.bloodTypes,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.enabled = true,
  });
  final String? label;
  final String? value;
  final List<String> bloodTypes;
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) => CustomDropdown<String>(
      label: label,
      hint: 'Select blood type',
      value: value,
      items: bloodTypes
          .map((bloodType) => DropdownItem(
                value: bloodType,
                text: bloodType,
                icon: const Icon(Icons.bloodtype, size: 20),
              ))
          .toList(),
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      enabled: enabled,
      prefixIcon: const Icon(Icons.bloodtype),
    );
}
