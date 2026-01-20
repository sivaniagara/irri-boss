import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/fertilizer_entities.dart';


Widget FertilizerSummaryCard(FertilizerEntity data) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(
      color: Colors.black, // 🔹 BLACK BORDER
      width: 0.5,
    ),),

    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          _summaryRow(
            Icons.calendar_month,
            "Date",
            data.data.isNotEmpty ? data.data.first.date : "-",
          ),
          _summaryRow(
            Icons.access_time,
            "Total Duration",
            data.totDuration,
          ),
          _summaryRow(
            Icons.water,
            "Total Flow",
            "${data.totFlow} Lts",
          ),
          _summaryRow(
            Icons.power,
            "Power Duration",
            "${data.powerDuration} ",
          ),
          _summaryRow(
            Icons.device_hub,
            "Controller Duration",
            "${data.ctrlDuration}",
          ),
          _summaryRow(
            Icons.device_hub,
            "Controller1 Duration",
            "${data.ctrlDuration1}",
          ),
        ],
      ),
    ),
  );
}

Widget _summaryRow(
    IconData icon,
    String title,
    String value,
    ) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: Colors.black),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Text(
          ":  $value",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
