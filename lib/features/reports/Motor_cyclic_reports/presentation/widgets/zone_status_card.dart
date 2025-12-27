import 'package:flutter/material.dart';
import '../../domain/entities/motor_cyclic_entities.dart';

class ZoneStatusCard extends StatelessWidget {
  final MotoCyclicZoneEntity zone;

  const ZoneStatusCard(this.zone, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // 🔹 TOP DURATION
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Text(
              zone.duration,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 VALVE ICON
          Image.asset("assets/images/common/valve_zone.png",width: 60,height: 60,),

          const SizedBox(height: 6),

          // 🔹 ZONE NUMBER
          Text(
            zone.zone,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const Spacer(),

          // 🔹 FLOW
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Text(
              "${zone.flow} Ltrs",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
