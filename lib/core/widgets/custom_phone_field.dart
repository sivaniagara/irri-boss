import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class CustomPhoneField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String initialCountryCode;
  final String? label;
  final InputDecoration? decoration;
  final Color? labelColor;
  final Color? textColor;
  final Widget? suffix;

  const CustomPhoneField({
    super.key,
    this.controller,
    this.initialValue,
    this.initialCountryCode = 'IN',
    this.decoration,
    this.labelColor,
    this.label,
    this.textColor,
    this.suffix,
  });

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  late TextEditingController _effectiveController;
  String? _currentCountryCode;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _effectiveController.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  String get fullPhoneNumber => _currentCountryCode != null
      ? '$_currentCountryCode${_effectiveController.text.trim()}'
      : '';

  String get countryCode => _currentCountryCode ?? '';

  @override
  Widget build(BuildContext context) {
    final defaultLabelColor = widget.labelColor ?? Colors.white54;
    final defaultTextColor = widget.textColor ??
        (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87);

    final defaultDecoration = InputDecoration(
      labelText: widget.label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black, width: 0.2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.black, width: 0.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 0.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 0.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 0.2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      labelStyle: const TextStyle(color: Colors.black45),
      prefixIcon: const Icon(Icons.phone, color: Colors.blue),
    );

    final effectiveDecoration = (widget.decoration ?? defaultDecoration).copyWith(
      suffix: _buildMergedSuffix(),
    );

    return IntlPhoneField(
      controller: _effectiveController,
      initialCountryCode: widget.initialCountryCode,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      flagsButtonMargin: EdgeInsets.only(right: 10),
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black, width: 0.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black, width: 0.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 0.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 0.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 0.2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        labelStyle: const TextStyle(color: Colors.black45),
        prefixIcon: const Icon(Icons.phone, color: Colors.blue),
        suffix: _buildMergedSuffix(),
      ),
      validator: (value) => value?.number.isEmpty ?? true ? 'Please enter a valid phone number' : null,
      style: TextStyle(color: defaultTextColor),
      dropdownTextStyle: TextStyle(color: defaultTextColor),
      dropdownDecoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        border: Border.all(color: Colors.black, width: 0.2),
      ),
      // decoration: effectiveDecoration,
      onChanged: (phone) {
        setState(() {
          _currentCountryCode = phone.countryCode;
        });
      },
      onCountryChanged: (country) {
        setState(() {
          _currentCountryCode = '+${country.dialCode}';
        });
      },
    );
  }

  Widget? _buildMergedSuffix() {
    final clearWidget = _effectiveController.text.isNotEmpty
        ? InkWell(
      onTap: () {
        _effectiveController.clear();
        setState(() {});
      },
      child: const Icon(Icons.clear, color: Colors.red),
    )
        : const SizedBox.shrink();

    Widget? baseSuffix;
    if (widget.decoration?.suffix != null) {
      baseSuffix = widget.decoration!.suffix;
    } else if (widget.suffix != null) {
      baseSuffix = widget.suffix;
    }

    if (baseSuffix == null) {
      return clearWidget;
    }

    return IntrinsicWidth(
      child: Row(
        children: [
          clearWidget,
          const SizedBox(width: 8),
          baseSuffix,
        ],
      ),
    );
  }
}