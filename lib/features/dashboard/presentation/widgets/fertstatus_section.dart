import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';

class FertStatusSection extends StatelessWidget {
  final String F1;
  final String F2;
  final String F3;
  final String F4;
  final String F5;
  final String F6;

  const FertStatusSection({
    super.key,
    required this.F1,
    required this.F2,
    required this.F3,
    required this.F4,
    required this.F5,
    required this.F6,
  });

  @override
  Widget build(BuildContext dialogContext) {
    return GlassCard(
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.all(6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Fertilizer:",
            style: TextStyle(fontSize: 13, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.start,
            children: [
              _buildButton("F1", F1),
              _buildButton("F2", F2),
              _buildButton("F3", F3),
              _buildButton("F4", F4),
              _buildButton("F5", F5),
              _buildButton("F6", F6),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, String value) {
    final bool isActive = value == "1";
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(45, 35), // smaller but uniform size
        backgroundColor: isActive ? Colors.green : Colors.red,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, color: Colors.white),
      ),
    );
  }
}
