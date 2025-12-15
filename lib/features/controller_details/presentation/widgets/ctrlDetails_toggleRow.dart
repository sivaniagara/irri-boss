import 'package:flutter/material.dart';

class ControllerToggleRow extends StatelessWidget {
  final String title;
  final bool isOn;

  const ControllerToggleRow({super.key, required this.title, required this.isOn});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Row(
            children: [
              const Icon(Icons.wifi, color: Colors.white70),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: isOn ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  isOn ? "ON" : "OFF",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
