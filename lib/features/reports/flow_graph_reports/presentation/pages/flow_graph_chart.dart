import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/flow_graph_entities.dart';

class FlowBarChart extends StatelessWidget {
  final List<FlowGraphDataEntity> data;

  const FlowBarChart(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(enabled: true),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),

          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                       color: Colors.black,
                    ),
                  );
                },
              ),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return const SizedBox();
                  }
                  final date = data[index].date;
                  final day = date != null && date.contains('/')
                      ? date.split('/').first
                      : '';

                  return Text(
                    day,
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),

          barGroups: _barGroups(),
        ),
      ),
    );
  }

  List<BarChartGroupData> _barGroups() {
    return List.generate(data.length, (index) {
      final flow =
          double.tryParse( data[index].totalFlow  ?? '0') ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: flow,
            color: Colors.blue,
            width: 14,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}
