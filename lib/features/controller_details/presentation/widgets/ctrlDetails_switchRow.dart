import 'package:flutter/material.dart';

import '../../../../core/theme/app_themes.dart';

class ControllerSwitchRow extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ControllerSwitchRow({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 65,
      child: Card(
        child: SwitchListTile(
          value: value,
          onChanged: onChanged,
          title: Text(title),
         ),
      ),
    );
  }
}