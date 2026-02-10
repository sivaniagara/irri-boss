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

Widget zoneCard(int index, dynamic zone) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Zone Header
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Zone ${index.toString().padLeft(3, '0')}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                "${zone.onTime} - ${zone.offTime}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const Divider(),

        _zoneRow(Icons.timer, "Duration", "${zone.duration} Hrs",
            Icons.science, "pH", "${zone.ph}"),
        _zoneRow(Icons.water, "Total Flow", "${zone.flow} Liters",
            Icons.flash_on, "EC", "${zone.ec}"),
        _zoneRow(Icons.speed, "Pressure In", "${zone.pressureIn}",
            Icons.speed, "Pressure Out", "${zone.pressureOut} Bar"),

        const SizedBox(height: 8),
      ],
    ),
  );
}

Widget _zoneRow(
    IconData i1,
    String t1,
    String v1,
    IconData i2,
    String t2,
    String v2,
    ) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(child: _zoneItem(i1, t1, v1)),
        Spacer(),
        Expanded(child: _zoneItem(i2, t2, v2)),
      ],
    ),
  );
}

Widget _zoneItem(IconData icon, String title, String value) {
  return Row(
    children: [
      CircleAvatar(
        radius: 16,
        backgroundColor: Colors.blue.shade50,
        child: Icon(icon, size: 16, color: Colors.blue),
      ),
      const SizedBox(width: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      )
    ],
  );
}
