import 'package:flutter/material.dart';

class ControllerActionButtons extends StatelessWidget {
  final List<ControllerButtonData> buttons;

  const ControllerActionButtons({
    super.key,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: buttons
            .map((btn) => ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btn.color,
            padding: const EdgeInsets.symmetric(
                horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: btn.onPressed,
          child: Text(
            btn.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ))
            .toList(),
      ),
    );
  }
}

class ControllerButtonData {
  final String title;
  final Color color;
  final VoidCallback onPressed;

  ControllerButtonData({
    required this.title,
    required this.color,
    required this.onPressed,
  });
}
