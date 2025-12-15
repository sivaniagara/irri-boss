import 'package:flutter/material.dart';

class ControllerInfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const ControllerInfoRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,style: const TextStyle(color: Colors.white, fontSize: 16)),
           if (valueWidget != null)
            valueWidget!
           else
            Text(
              value ?? "",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
        ],
      ),
    );
  }
}

