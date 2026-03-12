import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../../../../../core/theme/app_themes.dart';
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
    final int sNo = int.tryParse(entity.serialNo) ?? 0;

    // 🔹 Logic based on user request:
    // 012-013: Moisture (Gauges)
    // 024-025: Different (Gauges)
    final bool isGaugeView = (sNo == 12 || sNo == 13 || sNo == 24 || sNo == 25);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppThemes.primaryColor.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(sNo),
            const Divider(height: 1, thickness: 0.5, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: isGaugeView ? _gaugeContent() : _valveContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Header
  Widget _header(int sNo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppThemes.primaryColor.withOpacity(0.05),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppThemes.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              entity.serialNo.padLeft(3, '0'),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          if (entity.nodeName.isNotEmpty) ...[
            const SizedBox(width: 8),
            Text(
              entity.nodeName,
              style: const TextStyle(
                fontSize: 15,
                color: AppThemes.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          const Spacer(),
          _iconValue(Icons.battery_std, "${entity.batteryVot} v"),
          const SizedBox(width: 12),
          _iconValue(Icons.wb_sunny_outlined, "${entity.solarVot.padLeft(3, '0')} v"),
        ],
      ),
    );
  }

  /// 🔹 Valve View (Items 001-011, 014-023)
  Widget _valveContent() {
    return Row(
      children: [
        // Grey background for valve icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F4F7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Image.asset(
              _getValveImageAsset(),
              width: 50,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Grid of values
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  _valueCell("Value", "${entity.adcValue}${_getUnit(entity.serialNo)}"),
                  const SizedBox(width: 8),
                  _valueCell("Prs", "${entity.pressure} bar"),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _valueCell("Moi 1", "${entity.moisture1} cb"),
                  const SizedBox(width: 8),
                  _valueCell("Moi 2", "${entity.moisture2} cb"),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getValveImageAsset() {
    if (entity.feedback == "1") {
      return 'assets/images/common/valve_open.gif';
    } else if (entity.feedback == "0") {
      return 'assets/images/common/valve_stop.png';
    } else {
      return 'assets/images/common/valve_flag_icon.png';
    }
  }

  String _getUnit(String serialNo) {
    int s = int.tryParse(serialNo) ?? 0;
    if (s >= 1 && s <= 11) return "P";
    return "";
  }

  /// 🔹 Gauge View (Items 012, 013, 024, 025)
  Widget _gaugeContent() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFE),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _gaugeItem("Temperature", double.tryParse(entity.temperature) ?? 0, "°C", isTemp: true),
          _gaugeItem("Primary", double.tryParse(entity.moisture1) ?? 0, "Cb"),
          _gaugeItem("Secondary", double.tryParse(entity.moisture2) ?? 0, "Cb"),
        ],
      ),
    );
  }

  Widget _gaugeItem(String label, double value, String unit, {bool isTemp = false}) {
    String statusText = "";
    Color statusColor = Colors.orange;
    
    if (!isTemp) {
      if (label == "Primary") {
        statusText = "Too wet";
        statusColor = Colors.blue.shade700;
      } else {
        statusText = "Leaching";
        statusColor = Colors.orange.shade700;
      }
    }

    return Expanded(
      child: Column(
        children: [
          Text(
            label, 
            style: const TextStyle(
              fontSize: 11, 
              fontWeight: FontWeight.bold, 
              color: AppThemes.primaryColor
            )
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 80,
            child: SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                  minimum: 0,
                  maximum: isTemp ? 70 : 200,
                  showLabels: true,
                  labelFormat: '{value}',
                  labelOffset: 12,
                  axisLabelStyle: const GaugeTextStyle(fontSize: 7, fontWeight: FontWeight.bold),
                  showTicks: true,
                  majorTickStyle: const MajorTickStyle(length: 4, thickness: 1),
                  minorTickStyle: const MinorTickStyle(length: 2, thickness: 0.5),
                  startAngle: 180,
                  endAngle: 0,
                  radiusFactor: 1.0,
                  canScaleToFit: true,
                  axisLineStyle: const AxisLineStyle(
                    thickness: 0.15,
                    thicknessUnit: GaugeSizeUnit.factor,
                  ),
                  pointers: <GaugePointer>[
                    NeedlePointer(
                      value: value,
                      needleLength: 0.8,
                      needleStartWidth: 1,
                      needleEndWidth: 2,
                      knobStyle: const KnobStyle(knobRadius: 0.08),
                    )
                  ],
                  ranges: isTemp ? [
                    GaugeRange(startValue: 0, endValue: 15, color: Colors.blue, startWidth: 8, endWidth: 8),
                    GaugeRange(startValue: 15, endValue: 38, color: Colors.orange, startWidth: 8, endWidth: 8),
                    GaugeRange(startValue: 38, endValue: 70, color: Colors.red, startWidth: 8, endWidth: 8),
                  ] : [
                    GaugeRange(startValue: 0, endValue: 50, color: Colors.green, startWidth: 8, endWidth: 8),
                    GaugeRange(startValue: 50, endValue: 100, color: Colors.orange, startWidth: 8, endWidth: 8),
                    GaugeRange(startValue: 100, endValue: 200, color: Colors.red, startWidth: 8, endWidth: 8),
                  ],
                ),
              ],
            ),
          ),
          Text(
            "${value.toStringAsFixed(1)} $unit", 
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
          ),
          if (statusText.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 4, left: 2, right: 2),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  statusText,
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _valueCell(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title, 
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey.shade600)
            ),
            const SizedBox(height: 2),
            Text(
              value, 
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black)
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconValue(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppThemes.primaryColor),
        const SizedBox(width: 4),
        Text(
          value, 
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)
        ),
      ],
    );
  }
}
