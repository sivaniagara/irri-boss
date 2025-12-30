import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/power_entities.dart';
import '../../utils/timetodouble.dart';

class BarPieCard extends StatelessWidget {
  final PowerDatumEntity data;
  final int modelId ;

  const BarPieCard({super.key, required this.data, required this.modelId});
   @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
             Text(
              "${data.date ?? ""}",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const Text(
              "Hours",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12),

            /// BAR CHART
            SizedBox(
              height: 230,
              child: BarChart(
                BarChartData(
                  maxY: timeStringToDouble(data.totalPowerOnTime),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.black),
                      bottom: BorderSide(color: Colors.black),
                    ),
                  ),
                  titlesData: barTitles(modelId),
                  barGroups: buildBarGroups(data, modelId),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// PIE CHART
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                  sections: buildPieSections(data, modelId),
                ),
              ),
            ),

            const SizedBox(height: 8),
             Legend(modelId: modelId,),
          ],
        ),
      ),
    );
  }
}
/// 🔹 PIE SECTIONS
List<PieChartSectionData> buildPieSections(
    PowerDatumEntity data,
    int modelId,
    ) {
  final List<PieChartSectionData> sections = [];

  sections.add(
    PieChartSectionData(
      value: timeStringToDouble(data.totalPowerOnTime),
      title: timeStringToDouble(data.totalPowerOnTime).toStringAsFixed(1),
      color: Colors.cyan,
      radius: 50,
      titleStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );

  sections.add(
    PieChartSectionData(
      value: timeStringToDouble(data.motorRunTime),
      title: timeStringToDouble(data.motorRunTime).toStringAsFixed(1),
      color: Colors.green,
      radius: 50,
      titleStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    ),
  );

  if (modelId == 27) {
    sections.add(
      PieChartSectionData(
        value: timeStringToDouble(data.motorRunTime),
        title: timeStringToDouble(data.motorRunTime).toStringAsFixed(1),
        color: Colors.lime,
        radius: 50,
        titleStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  return sections;
}


/// 🔹 LEGEND DOT
class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.black)),
      ],
    );
  }
}

class Legend extends StatelessWidget {
  final int modelId;

  const Legend({super.key, required this.modelId});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _LegendDot(color: Colors.cyan, text: "Power ON"),
        const SizedBox(width: 16),
        const _LegendDot(color: Colors.green, text: "Motor ON"),
        if (modelId == 27) ...[
          const SizedBox(width: 16),
          const _LegendDot(color: Colors.lime, text: "Motor2 ON"),
        ],
      ],
    );
  }
}



/// 🔹 BAR TITLES
FlTitlesData barTitles(int modelId) {
  return FlTitlesData(
    leftTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 36,
        getTitlesWidget: (value, meta) {
          return Text(
            value.toInt().toString(),
            style: const TextStyle(color: Colors.black, fontSize: 12),
          );
        },
      ),
    ),

    bottomTitles: AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        getTitlesWidget: (value, meta) {
          switch (value.toInt()) {
            case 0:
              return const Text("Power ON",
                  style: TextStyle(color: Colors.black));
            case 1:
              return const Text("Motor ON",
                  style: TextStyle(color: Colors.black));
            case 2:
              if (modelId == 27) {
                return const Text("Motor2 ON",
                    style: TextStyle(color: Colors.black));
              }
              return const SizedBox();
            default:
              return const SizedBox();
          }
        },
      ),
    ),

    topTitles:
    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles:
    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
  );
}

/// 🔹 BAR GROUPS
List<BarChartGroupData> buildBarGroups(
    PowerDatumEntity data,
    int modelId,
    ) {
  final List<BarChartGroupData> groups = [];

  groups.add(
    BarChartGroupData(
      x: 0,
      barRods: [
        BarChartRodData(
          toY: timeStringToDouble(data.totalPowerOnTime),
          width: 30,
          color: Colors.cyan,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    ),
  );

  groups.add(
    BarChartGroupData(
      x: 1,
      barRods: [
        BarChartRodData(
          toY: timeStringToDouble(data.motorRunTime),
          width: 30,
          color: Colors.green,
          borderRadius: BorderRadius.circular(6),
        ),
      ],
    ),
  );

  if (modelId == 27) {
    groups.add(
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(
            toY: timeStringToDouble(data.motorRunTime),
            width: 30,
            color: Colors.lime,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      ),
    );
  }

  return groups;
}