import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CommonDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final Color bgColor;
  final Color borderColor;

  const CommonDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.bgColor = const Color(0xFF0A4D68),
    this.borderColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1.0),
        ),
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: bgColor,
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item, style: const TextStyle(color: Colors.white)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}