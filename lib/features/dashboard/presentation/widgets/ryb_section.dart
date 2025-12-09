import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';

class RYBSection extends StatelessWidget {
  final String r, y, b;
  final String c1, c2, c3;

  const RYBSection({
    super.key,
    required this.r,
    required this.y,
    required this.b,
    required this.c1,
    required this.c2,
    required this.c3,
  });

  Widget _buildBox(Color color, String line1, String line2, String line3) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(2),
        margin: const EdgeInsets.all(2),
        child: Container(
             child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   Icon(Icons.power,color: color),
                  Text(line1, style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.account_tree_rounded,color: color),
                  Text(line2,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                ],
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(Icons.ac_unit,color: color),
                  Text(line3,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext dialogContext) {
    return Row(
      children: [
        _buildBox(Colors.red, "RY $r V", "R $r V", "C1 $c1 A"),
        _buildBox(Colors.yellow, "YB $y V", "Y $y V", "C2 $c2 A"),
        _buildBox(Colors.blueAccent, "BR $b V", "B $b V", "C3 $c3 A"),
      ],
    );
  }
}
