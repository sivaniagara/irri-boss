import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';

import '../../domain/entities/moisture_entities.dart';

class MoistureValveCard extends StatelessWidget {
  final int index;
  final MostEntity entity;

  const MoistureValveCard({
    super.key,
    required this.index,
    required this.entity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 10),
            _content(),
          ],
        ),
      ),
    );
  }

  /// 🔹 Top row: 001 | Battery | Solar
  Widget _header() {
    return Row(
      children: [
        Text(
          entity.serialNo.padLeft(3, '0'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const Spacer(),
        _iconValue(
          Icons.battery_full,
          "${entity.batteryVot} v",

        ),
        const SizedBox(width: 12),
        _iconValue(
          Icons.solar_power,
          "${entity.solarVot} v",
        ),
      ],
    );
  }

  /// 🔹 Main content row
  Widget _content() {
    return Row(
      children: [
        _valveIcon(),
        const SizedBox(width: 12),
        Expanded(child: _valueTable()),
      ],
    );
  }

  Widget _valveIcon() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.settings_input_component,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  Widget _valueTable() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          _tableRow(
            leftTitle: "Value",
            leftValue: entity.adcValue,
            rightTitle: "Prs",
            rightValue: "${entity.pressure} bar",
          ),
          _divider(),
          _tableRow(
            leftTitle: "Moi 1",
            leftValue: "${entity.moisture1} cb",
            rightTitle: "Moi 2",
            rightValue: "${entity.moisture2} cb",
          ),
        ],
      ),
    );
  }

  Widget _tableRow({
    required String leftTitle,
    required String leftValue,
    required String rightTitle,
    required String rightValue,
  }) {
    return Row(
      children: [
        _cell(title: leftTitle, value: leftValue),
        _cell(title: rightTitle, value: rightValue),
      ],
    );
  }

  Widget _cell({
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade400,
    );
  }

  Widget _iconValue(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 18,color: AppThemes.primaryColor,),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
