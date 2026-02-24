import 'package:flutter/material.dart';
import '../../../../../core/theme/app_themes.dart';
import '../../domain/entities/fertilizer_entities.dart';

Widget FertilizerSummaryCard(FertilizerEntity data) {
  return Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppThemes.primaryColor.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            _mainSummaryItem(
              Icons.water_drop_rounded,
              "Total Flow",
              "${data.totFlow}",
              "Lts",
              const Color(0xFF2196F3),
            ),
            Container(width: 1, height: 40, color: Colors.grey[200]),
            _mainSummaryItem(
              Icons.timer_rounded,
              "Total Time",
              data.totDuration,
              "",
              const Color(0xFF4CAF50),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1, thickness: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              style: const TextStyle(fontSize: 15, color: Colors.black),
              "Summary",
            ),
            _subSummaryItem(Icons.bolt_rounded, "Power", data.powerDuration),
            _subSummaryItem(Icons.settings_input_component_rounded, "Ctrl 1", data.ctrlDuration),
            _subSummaryItem(Icons.settings_input_component_rounded, "Ctrl 2", data.ctrlDuration1),
          ],
        ),
      ],
    ),
  );
}

Widget _mainSummaryItem(IconData icon, String title, String value, String unit, Color color) {
  return Expanded(
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
              children: [
                TextSpan(text: value),
                if (unit.isNotEmpty)
                  TextSpan(
                    text: " $unit",
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.normal),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _subSummaryItem(IconData icon, String title, String value) {
  return Column(
    children: [
      Icon(icon, size: 18, color: AppThemes.primaryColor),
      const SizedBox(height: 4),
      Text(title, style: const TextStyle(fontSize: 10, color: Colors.black)),
      const SizedBox(height: 2),
      Text(
        value,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    ],
  );
}
