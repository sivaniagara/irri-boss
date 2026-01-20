import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/fertilizer_reports/domain/entities/fertilizer_entities.dart';

 
class FertilizerCard extends StatelessWidget {
  final FertilizerDatumEntity zone;

  const FertilizerCard(this.zone, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade500,
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
              zone.fertPump,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Icon(Icons.account_tree,)),

          // 🔹 ZONE NUMBER
          Text(
            zone.zoneNumber,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

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
