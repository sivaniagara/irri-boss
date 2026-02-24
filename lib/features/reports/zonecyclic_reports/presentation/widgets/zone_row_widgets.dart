import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/domain/entities/zone_cyclic_entities.dart';

Widget summaryItem(String title, String value, IconData icon, Color iconColor) {
  return Expanded(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF2196F3), size: 14),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value.split(' ').first,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                if (value.contains(' '))
                  TextSpan(
                    text: ' ${value.split(' ').last}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget zonecyclicCard(int index, ZoneCyclicDetailEntity zone) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 6),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Row: Zone, Time Range, Date
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                zone.zone,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  "${zone.onTime} - ${zone.offTime}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              zone.date,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: Color(0xFFEEEEEE)),
        ),
        // Row 1: Duration and pH
        Row(
          children: [
            _expandedInfo(Icons.access_time_rounded, "Duration : ", zone.duration, " Hrs", flex: 3),
            _expandedInfo(Icons.opacity, "pH : ", zone.ph, "", flex: 2, isRightAligned: true),
          ],
        ),
        const SizedBox(height: 14),
        // Row 2: Total Flow and EC
        Row(
          children: [
            _expandedInfo(Icons.waves_rounded, "Total Flow : ", zone.flow, " Liters", flex: 3),
            _expandedInfo(Icons.opacity, "EC : ", "0", "", flex: 2, isRightAligned: true),
          ],
        ),
        const SizedBox(height: 14),
        // Row 3: Pressure and Total Cycle
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Color(0xFFE3F2FD),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.speed, size: 16, color: Color(0xFF2196F3)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    children: [
                      const TextSpan(text: "Pressure   in : "),
                      TextSpan(
                        text: zone.pressureIn,
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: " Out : "),
                      TextSpan(
                        text: zone.pressureOut,
                        style: const TextStyle(
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(
                        text: " Bar",
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "Total Cycle : 0",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF2196F3),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _expandedInfo(IconData icon, String label, String value, String unit, {int flex = 1, bool isRightAligned = false}) {
  return Expanded(
    flex: flex,
    child: Row(
      mainAxisAlignment: isRightAligned ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Color(0xFFE3F2FD),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF2196F3)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                children: [
                  TextSpan(text: label),
                  TextSpan(
                    text: value,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                  if (unit.isNotEmpty)
                    TextSpan(
                      text: " $unit",
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
