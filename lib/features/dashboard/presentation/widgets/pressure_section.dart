import 'package:flutter/material.dart';

class PressureSection extends StatelessWidget {
  final String prsIn;
  final String prsOut;
  final String activeZone;
  final String fertlizer ;

  const PressureSection({
    super.key,
    required this.prsIn,
    required this.prsOut,
    required this.activeZone,
    required this.fertlizer,
  });

  @override
  Widget build(BuildContext dialogContext) {
    return  Column(
      children: [
        Text("$fertlizer",style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Prs IN: $prsIn",style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
            Text(activeZone, style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.green)),
            Text("Prs OUT: $prsOut",style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.white)),
          ],
        ),
      ],
    );
  }
}
