import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart'; // Keep for countries data; remove full package if extracting data elsewhere

import 'custom_country_picker.dart';

class CustomPhoneField extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final String initialCountryCode;
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
    this.textColor,
    this.suffix,
  });

  @override
  State<CustomPhoneField> createState() => CustomPhoneFieldState();
}

class CustomPhoneFieldState extends State<CustomPhoneField> {
  late final TextEditingController _effectiveController;
  late final GlobalKey<FormFieldState> _fieldKey;
  late String _countryCode;
  late Country _selectedCountry;

  @override
  void initState() {
    super.initState();
    _fieldKey = GlobalKey<FormFieldState>();
    _effectiveController = widget.controller ?? TextEditingController();

    final initialCountry = countries.firstWhere(
          (country) => country.code == widget.initialCountryCode,
      orElse: () => countries.firstWhere((country) => country.code == 'IN'),
    );
    _selectedCountry = initialCountry;
    _countryCode = '+${_selectedCountry.dialCode}';

    if (widget.controller == null && widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _effectiveController.text = widget.initialValue!;
    }
  }

  void _showCountryPicker() async {
    await CustomCountryPicker.show(
      context: context,
      onCountrySelected: (country) {
        setState(() {
          _selectedCountry = country;
          _countryCode = '+${country.dialCode}';
        });
        _fieldKey.currentState?.didChange(_effectiveController.text);
      },
      initialCountryCode: _selectedCountry.code,
    );
  }

  Widget _buildCountrySelector() {
    return GestureDetector(
      onTap: _showCountryPicker,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 9, horizontal: 2),
        decoration: BoxDecoration(
          border: Border(right: BorderSide(color: Colors.grey.shade300)),
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_selectedCountry.flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Text(
              _countryCode,
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  String get phoneNumber {
    return _effectiveController.text;
  }

  String get countryCode {
    return _countryCode;
  }

  Color _getDefaultColor() {
    return Colors.white;
    return Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a valid phone number';
    }
    if (_selectedCountry.code == 'IN' && (value.length < 10 || value.length > 10)) {
      return 'Phone number must be 10 digits for India';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Phone number must contain only digits';
    }
    return null;
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

  @override
  Widget build(BuildContext context) {
    final defaultLabelColor = widget.labelColor ?? Colors.white54;
    final defaultTextColor = widget.textColor ?? _getDefaultColor();

    // Get effective decoration (default or custom)
    InputDecoration effectiveDecoration = widget.decoration ??
        InputDecoration(
          labelText: 'Phone Number',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(0),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(0),
          ),
          errorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(0),
          ),
          focusedErrorBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
            borderRadius: BorderRadius.circular(0),
          ),
          disabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(0),
          ),
          prefixStyle: const TextStyle(color: Colors.black),
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 12,
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
        );

    // Apply merged suffix to effective decoration
    effectiveDecoration = effectiveDecoration.copyWith(
      suffix: _buildMergedSuffix(),
      labelStyle: effectiveDecoration.labelStyle?.copyWith(color: defaultLabelColor) ??
          TextStyle(color: defaultLabelColor),
    );

    return Row(
      children: [
        _buildCountrySelector(),
        const SizedBox(width: 2),
        Expanded(
          child: TextFormField(
            key: _fieldKey,
            controller: _effectiveController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: defaultTextColor),
            decoration: effectiveDecoration
                .copyWith(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0),
                borderSide: BorderSide.none,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(0),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(0),
              ),
              errorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent),
                borderRadius: BorderRadius.circular(0),
              ),
              focusedErrorBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
                borderRadius: BorderRadius.circular(0),
              ),
              disabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            onChanged: (value) {
              setState(() {});
            },
            validator: _validatePhoneNumber,
          ),
        ),
      ],
    );
  }
}