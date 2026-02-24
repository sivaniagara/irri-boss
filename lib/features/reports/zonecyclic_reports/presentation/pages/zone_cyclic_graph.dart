import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/no_data.dart';
import '../../domain/entities/zone_cyclic_entities.dart';

class ZoneCyclicGraph extends StatelessWidget {
  final List<ZoneCyclicDetailEntity> zoneList;
  final String totalFlow;

  const ZoneCyclicGraph({
    super.key,
    required this.zoneList,
    required this.totalFlow,
  });

  @override
  Widget build(BuildContext context) {
    return zoneList.isEmpty
        ? noDataNew
        : Column(
            children: [
              const SizedBox(height: 20),
              Expanded(
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          "Hours / Litres",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Container(
                          padding: const EdgeInsets.only(right: 20, top: 10),
                          width: zoneList.length * 100 > MediaQuery.of(context).size.width 
                              ? zoneList.length * 100 
                              : MediaQuery.of(context).size.width - 60,
                          child: BarChart(
                            BarChartData(
                              maxY: _calculateMaxY(),
                              barTouchData: barTouchData(zoneList),
                              titlesData: zoneBarTitles(zoneList),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.withOpacity(0.1),
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              barGroups: buildZoneBarGroups(zoneList),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _legend(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    children: [
                      const TextSpan(text: "Total Flow: "),
                      TextSpan(
                        text: "$totalFlow L",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
  }

  double _calculateMaxY() {
    double max = 0;
    for (final z in zoneList) {
      final v = timeStringToDouble(z.duration);
      if (v > max) max = v;
    }
    return max == 0 ? 5 : max + (max * 0.2);
  }

  BarTouchData barTouchData(List<ZoneCyclicDetailEntity> zones) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipRoundedRadius: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final zone = zones[group.x.toInt()];
          return BarTooltipItem(
            '${zone.zone}\n',
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            children: [
              TextSpan(
                text: zone.duration,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }

  List<BarChartGroupData> buildZoneBarGroups(List<ZoneCyclicDetailEntity> zones) {
    return List.generate(zones.length, (index) {
      final zone = zones[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: timeStringToDouble(zone.duration),
            width: 22,
            color: zoneColor(index),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calculateMaxY(),
              color: Colors.grey.withOpacity(0.05),
            ),
          ),
        ],
      );
    });
  }

  FlTitlesData zoneBarTitles(List<ZoneCyclicDetailEntity> zones) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 40,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= zones.length) return const SizedBox();
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                zones[index].zone.replaceAll('Zone ', ''),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            );
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Color zoneColor(int index) {
    final colors = [
      const Color(0xFF2196F3), // Primary Blue
      const Color(0xFF4CAF50), // Success Green
      const Color(0xFFFF9800), // Warning Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFE91E63), // Pink
    ];
    return colors[index % colors.length];
  }

  double timeStringToDouble(String time) {
    try {
      final parts = time.split(':');
      if (parts.length < 2) return 0.0;
      final h = double.parse(parts[0]);
      final m = double.parse(parts[1]);
      final s = parts.length > 2 ? double.parse(parts[2]) : 0.0;
      return h + (m / 60) + (s / 3600);
    } catch (e) {
      return 0.0;
    }
  }

  Widget _legend() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Center(
        child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemCount: zoneList.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: zoneColor(index),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  zoneList[index].zone,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
