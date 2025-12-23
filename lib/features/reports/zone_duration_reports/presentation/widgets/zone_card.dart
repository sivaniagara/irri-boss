
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/zone_duration_entities.dart';

Widget zoneCardDuration(ZoneDurationDatumEntity zone) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),side: const BorderSide(
      color: Colors.black, // 🔹 BLACK BORDER
      width: 0.5,
    ),),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// 🔹 BLUE HEADER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Program ${zone.program}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "ZONE ${zone.zone}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        /// 🔹 DETAILS
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _infoPair("EC", zone.ec, "PH", zone.ph),
              _infoPair("Prs IN", zone.pressureIn, "Prs OUT", zone.pressureOut),
              _infoPair("Duration", zone.duration, "Flow Lit", zone.flow),
              _infoPair("Well Level", zone.wellLevel, "Percentage", "${zone.wellPercentage}%",),
            ],
          ),
        ),
      ],
    ),
  );
}


Widget _infoPair(
    String t1,
    String v1,
    String t2,
    String v2,
    ) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(child: _infoText(t1, v1)),
        Expanded(child: _infoText(t2, v2)),
      ],
    ),
  );
}

Widget _infoText(String title, String value) {
  return RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: "$title: \t",
          style: const TextStyle(
            color: Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
        TextSpan(
          text: value,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
