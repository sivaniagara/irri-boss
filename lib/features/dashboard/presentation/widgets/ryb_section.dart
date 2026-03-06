import 'package:flutter/material.dart';

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

  Widget _buildBox(BuildContext context, Color color, String phase, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: color,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              phase,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Container(
              width: 40,
              height: 0.8,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 5),
            Text(
              '$value V',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildBox(context, const Color(0xffE21E11), 'R Phase', r),
            _buildBox(context, const Color(0xffFEC106), 'Y Phase', y),
            _buildBox(context, const Color(0xff6C8DB7), 'B Phase', b),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color(0xffE1EEEE),
          ),
          child: Center(
            child: Text(
              'Current : C1 ${c1}A , C2 ${c2}A , C3 ${c3}A',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
