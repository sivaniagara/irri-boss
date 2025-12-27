import 'package:flutter/material.dart';

class DripStandaloneCard extends StatelessWidget {
  final bool isOn;

  const DripStandaloneCard({super.key, required this.isOn});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _decoration(),
      child: Row(
        children: [
          const Icon(Icons.water_drop, color: Colors.green),
          const SizedBox(width: 8),
          const Text(
            "DRIP STANDALONE",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Switch(value: isOn, onChanged: (_) {}),
          const Icon(Icons.send, color: Colors.blue),
        ],
      ),
    );
  }

  BoxDecoration _decoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    );
  }
}

