import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';
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
      child: Container(
        padding: const EdgeInsets.all(2),
        margin: const EdgeInsets.all(2),
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(16),
             border: BoxBorder.all(width: 0.3),
             color: color,
            ),
           child: Column(
          children: [
            SizedBox(height: 5,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                 Icon(Icons.power,color: Colors.white70),
                Text(line1, style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
              ],
            ),
            SizedBox(height: 5,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.account_tree_rounded,color: Colors.white70),
                Text(line2,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
              ],
            ),
            SizedBox(height: 5,),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.ac_unit,color: Colors.white70),
                Text(line3,style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black)),
              ],
            ),
            SizedBox(height: 5,),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext dialogContext) {
    return Row(
      children: [
        _buildBox( Colors.redAccent, "RY $r V", "R $r V", "C1 $c1 A"),
        _buildBox(Colors.yellow, "YB $y V", "Y $y V", "C2 $c2 A"),
        _buildBox(Colors.blueAccent, "BR $b V", "B $b V", "C3 $c3 A"),
      ],
    );
  }
}
