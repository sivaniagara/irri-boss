import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class PressureGaugeSection extends StatelessWidget {
  final double prsIn;
  final double prsOut;
  final double fertFlow;

  const PressureGaugeSection({
    super.key,
    required this.prsIn,
    required this.prsOut,
    required this.fertFlow,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildGaugeWithLabel("Prs In", prsIn, "bar"),
        _buildGaugeWithLabel("Prs Out", prsOut, "bar"),
        _buildGaugeWithLabel("Flow Rate", fertFlow, "LT/S"),
      ],
    );
  }

  Widget _buildGaugeWithLabel(String label, double value, String type) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF424242), // Darker grey for better visibility
            ),
          ),
          const SizedBox(height: 8),
          _buildGauge(value, type),
        ],
      ),
    );
  }

  Widget _buildGauge(double value, String type) {
    final double maxValue = type == "bar" ? 10 : 100;

    return SizedBox(
      width: 90,
      height: 90,
      child: SfRadialGauge(
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: maxValue,
            showLabels: false,
            showTicks: false,
            startAngle: 180,
            endAngle: 0, // Fixed: Top semi-circle
            centerY: 0.7,
            axisLineStyle: const AxisLineStyle(
              thickness: 0.15,
              thicknessUnit: GaugeSizeUnit.factor,
              color: Color(0xFFE1EEEE),
            ),
            pointers: [
              RangePointer(
                value: value.clamp(0, maxValue),
                width: 0.15,
                sizeUnit: GaugeSizeUnit.factor,
                gradient: const SweepGradient(
                  colors: <Color>[
                    Colors.green,
                    Colors.orange,
                    Colors.red,
                  ],
                  stops: <double>[0.3, 0.6, 1.0],
                ),
                enableAnimation: true,
              ),
              NeedlePointer(
                value: value.clamp(0, maxValue),
                needleEndWidth: 3,
                needleLength: 0.7,
                needleColor: Colors.black54,
                knobStyle: const KnobStyle(
                  knobRadius: 0.08,
                  sizeUnit: GaugeSizeUnit.factor,
                  color: Colors.black54,
                ),
              ),
            ],
            annotations: [
              GaugeAnnotation(
                widget: Text(
                  "$value\n$type",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                angle: 90,
                positionFactor: 0.5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
