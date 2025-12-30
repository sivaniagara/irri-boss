import 'package:flutter/material.dart';

import '../../domain/entities/standalone_entities.dart';

class ZoneStatusCardStandAlone extends StatelessWidget {
  final StandaloneDatumEntity zone;

  const ZoneStatusCardStandAlone(this.zone, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.green.shade500,
      ),
      child: Column(
        children: [
          // 🔹 TOP DURATION
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              zone.zone,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
              Expanded(child: Icon(Icons.touch_app,)),
           // 🔹 FLOW
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Text(
              "${zone.duration}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
