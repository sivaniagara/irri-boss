import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/power_entities.dart';
import '../../utils/timetodouble.dart';

class BarPieCard extends StatefulWidget {
  final PowerDatumEntity data;
  final int modelId;

  const BarPieCard({
    super.key,
    required this.data,
    required this.modelId,
  });

  @override
  State<BarPieCard> createState() => _BarPieCardState();
}

class _BarPieCardState extends State<BarPieCard> {
  bool showBarChart = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Legend(modelId: widget.modelId,pie: showBarChart),


            /// HEADER + TOGGLE ICON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                showBarChart ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${widget.data.date ?? ""}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      "Hours",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ) : Container(),

                IconButton(
                  icon: Icon(
                    showBarChart
                        ? Icons.pie_chart
                        : Icons.bar_chart,
                    color: Colors.blue,
                  ),
                  onPressed: () {
                    setState(() {
                      showBarChart = !showBarChart;
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// BAR / LINE CHART
            SizedBox(
              height: 230,
              child: showBarChart
                  ? BarChart(
                BarChartData(
                  maxY: timeStringToDouble(
                      widget.data.totalPowerOnTime),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(color: Colors.black),
                      bottom: BorderSide(color: Colors.black),
                    ),
                  ),
                  titlesData: barTitles(widget.modelId),
                  barGroups:
                  buildBarGroups(widget.data, widget.modelId),

                ),
              )
                  : SizedBox(
                height: 230,
                child: PieChart(
                  PieChartData(
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    sections:
                    buildPieSections(widget.data, widget.modelId),
                  ),
                ),
              ),

            ),

            const SizedBox(height: 20),

            /// PIE CHART


            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// 🔹 LINE CHART DATA
LineChartData buildLineChart(
    PowerDatumEntity data,
    int modelId,
    ) {
  return LineChartData(
    gridData: FlGridData(show: false),
    borderData: FlBorderData(
      show: true,
      border: const Border(
        left: BorderSide(color: Colors.black),
        bottom: BorderSide(color: Colors.black),
      ),
    ),
    titlesData: barTitles(modelId),
    lineBarsData: [
      LineChartBarData(
        spots: [
          FlSpot(0, timeStringToDouble(data.totalPowerOnTime)),
          FlSpot(1, timeStringToDouble(data.motorRunTime)),
          if (modelId == 27)
            FlSpot(2, timeStringToDouble(data.motorRunTime)),
        ],
        isCurved: true,
        barWidth: 3,
        color: Colors.cyan,
        dotData: FlDotData(show: true),
      ),
    ],
  );
}

/// 🔹 PIE SECTIONS
List<PieChartSectionData> buildPieSections(
    PowerDatumEntity data,
    int modelId,
    ) {
  final double powerOn =
  timeStringToDouble(data.totalPowerOnTime);

  final double motorOn =
  timeStringToDouble(data.motorRunTime);

  final double motorOff =
  timeStringToDouble(data.motorIdleTime ?? "0");

  final double total = powerOn + motorOn + motorOff;

  double percent(double value) =>
      total == 0 ? 0 : (value / total) * 100;

  final List<PieChartSectionData> sections = [];

  /// 🔹 POWER ON
  sections.add(
    PieChartSectionData(
      value: percent(powerOn),
      title:
      "Power ON\n${percent(powerOn).toStringAsFixed(1)}%",
      color: Colors.cyan,
      radius: 50,
      titlePositionPercentageOffset: 0.6,
      titleStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    ),
  );

  /// 🔹 MOTOR ON
  sections.add(
    PieChartSectionData(
      value: percent(motorOn),
      title:
      "Motor ON\n${percent(motorOn).toStringAsFixed(1)}%",
      color: Colors.green,
      radius: 50,
      titlePositionPercentageOffset: 0.6,
      titleStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    ),
  );

  /// 🔹 MOTOR OFF
  sections.add(
    PieChartSectionData(
      value: percent(motorOff),
      title:
      "Motor OFF\n${percent(motorOff).toStringAsFixed(0)}%",
      color: Colors.orange,
      radius: 50,
      titlePositionPercentageOffset: 0.6,
      titleStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
        fontSize: 11,
      ),
    ),
  );

  /// 🔹 OPTIONAL MOTOR 2
  if (modelId == 27) {
    sections.add(
      PieChartSectionData(
        value: percent(motorOn),
        title:
        "Motor2 ON\n${percent(motorOn).toStringAsFixed(1)}%",
        color: Colors.lime,
        radius: 50,
        titlePositionPercentageOffset: 0.6,
        titleStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  return sections;
}


/// 🔹 LEGEND
class Legend extends StatelessWidget {
  final int modelId;
  final bool pie;

  const Legend({super.key, required this.modelId, required this.pie});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const _LegendDot(color: Colors.cyan, text: "Power ON"),
        const SizedBox(width: 16),
        const _LegendDot(color: Colors.green, text: "Motor ON"),
        const SizedBox(width: 16),
        !pie ? const _LegendDot(color: Colors.orange, text: "Motor OFF") : Container(),
        if (modelId == 27) ...[
          const SizedBox(width: 16),
          const _LegendDot(color: Colors.lime, text: "Motor2 ON"),
        ],
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendDot({
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
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
            style:
            const TextStyle(color: Colors.black, fontSize: 12),
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
              return const Text("Power ON");
            case 1:
              return const Text("Motor ON");
            case 2:
              return modelId == 27
                  ? const Text("Motor2 ON")
                  : const SizedBox();
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
    )
{
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
