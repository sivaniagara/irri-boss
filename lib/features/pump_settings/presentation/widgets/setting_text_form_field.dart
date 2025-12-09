import 'package:flutter/material.dart';

class SettingTextFormField extends StatelessWidget {
  const SettingTextFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSaved,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.style,
    this.cursorColor,
    this.textAlign = TextAlign.start,
    this.onFieldSubmitted,
    this.onEditingComplete,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool autofocus;
  final bool readOnly;
  final bool? enabled;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextStyle? style;
  final Color? cursorColor;
  final TextAlign textAlign;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;

  @override
  Widget build(BuildContext dialogContext) {
    final theme = Theme.of(dialogContext);

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofocus: autofocus,
      readOnly: readOnly,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      style: style ?? theme.textTheme.titleMedium,
      cursorColor: cursorColor ?? theme.colorScheme.primary,
      textAlign: textAlign,
      onFieldSubmitted: onFieldSubmitted,
      onEditingComplete: onEditingComplete,
      decoration: const InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isDense: true,
        counterText: '',
      ),
    );
  }
}