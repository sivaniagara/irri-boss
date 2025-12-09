import 'package:flutter/material.dart';

class SettingSwitch extends StatelessWidget {
  const SettingSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext dialogContext) {
    return Switch(
      value: value,
      onChanged: onChanged,
    );
  }
}