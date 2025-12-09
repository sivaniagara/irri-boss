import 'package:flutter/material.dart';

class HeaderSection extends StatelessWidget {
  final String ctrlName;
  final bool isMqttConnected;

  const HeaderSection({super.key, required this.ctrlName, required this.isMqttConnected});

  @override
  Widget build(BuildContext dialogContext) {
    return Row(
      children: [
        const Icon(Icons.call, color: Colors.blue),
        Expanded(
          child: Center(
            child: Text(ctrlName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.white)),
          ),
        ),
        Icon(
          Icons.circle,
          color: isMqttConnected ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}
