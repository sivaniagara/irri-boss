// ===================== WIDGETS =====================

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/domain/entities/motor_cyclic_entities.dart';

Widget infoRow(String title, String value,IconData vIcon) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    child: Row(
      children: [
        Icon(vIcon,color: Colors.black,),
        SizedBox(width: 5,),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        Text(
          ":  $value",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget zoneCard(int index, dynamic zone,) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade400),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 ZONE HEADER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          color: Colors.grey.shade300,
          child: Text(
            "ZONE ${index.toString().padLeft(3, '0')}",
            style: const TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

         _zoneRow("On Time:", zone.onTime, "Off Time:", zone.offTime),
        _zoneRow("Duration:", zone.duration, "Flow:", "${zone.flow} Lts"),
        _zoneRow("EC:", zone.ec, "pH:", zone.ph),
        _zoneRow("Pressure In:", zone.pressureIn,"Pressure Out:", zone.pressureOut),
      ],
    ),
  );
}


Widget _zoneRow(
    String t1,
    String v1,
    String t2,
    String v2,
    ) {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "$t1  ",
                  style: const TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: v1,
                  style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        if (t2.isNotEmpty)
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "$t2  ",
                    style: const TextStyle(color: Colors.black54,fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: v2,
                    style: const TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
