import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
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
        _buildGauge(prsIn,"bar"),
        _buildGauge(prsOut,"bar"),
        _buildGauge(fertFlow,"LT/S"),
      ],
    );
  }

  Widget _buildGauge(double value, String type) {
    final double maxValue = type == "bar" ? 10 : 100;

    return GlassCard(
      padding:  const EdgeInsets.all(4),
      margin:  const EdgeInsets.all(4),
      child: SizedBox(
        width: 90,
        height: 90,
        child: SfRadialGauge(
          axes: [
            RadialAxis(
              minimum: 0,
              maximum: maxValue,
              showLabels: false,
              showTicks: false,
              axisLineStyle: const AxisLineStyle(
                thickness: 0.15,
                thicknessUnit: GaugeSizeUnit.factor,
                color: Colors.transparent,
              ),
              pointers: [
                // Full color background (full arc)
                RangePointer(
                  value: maxValue, // full arc
                  width: 0.30,
                  sizeUnit: GaugeSizeUnit.factor,
                  gradient: SweepGradient(
                    colors: const <Color>[
                      Colors.tealAccent,
                      Colors.orangeAccent,
                      Colors.redAccent,
                      Colors.red,
                    ],
                    stops: type == "bar"
                        ? const <double>[0.10, 0.30, 0.60, 1.00]
                        : const <double>[0.15, 0.50, 0.70, 1.00],
                  ),
                  enableAnimation: true,
                ),
                // Needle showing actual value
                NeedlePointer(
                  value: value.clamp(0, maxValue),
                  needleEndWidth: 3,
                  needleColor: Colors.white,
                ),
              ],
              annotations: [
                GaugeAnnotation(
                  widget: Text(
                    "$value $type",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  angle: 90,
                  positionFactor: 0.8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


}
