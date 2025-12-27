import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/no_data.dart';
import '../../domain/entities/zone_cyclic_entities.dart';

// class ZoneCyclicGraph extends StatelessWidget {
//   final ZoneCyclicEntity zones;
//
//   const ZoneCyclicGraph({super.key, required this.zones});
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Column(
//         children: [
//           // 🔹 LEGEND
//            Expanded(
//             child: Row(
//               children: [
//                 // 🔹 LEFT AXIS LABEL
//                 const Padding(
//                   padding: EdgeInsets.only(left: 8),
//                   child: RotatedBox(
//                     quarterTurns: 3,
//                     child: Text(
//                       "Hours / Litres",
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//
//                 // 🔹 GRAPH
//                 Expanded(
//                   child: SingleChildScrollView(
//                     scrollDirection: Axis.horizontal,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: SizedBox(
//                         width: zones.data.length * 120,
//                         child: BarChart(
//                           BarChartData(
//                             alignment: BarChartAlignment.spaceAround,
//                             maxY: _calculateMaxY(),
//                             barTouchData: barTouchData(zones.data[0].zoneList),
//                             titlesData: zoneBarTitles(zones.data[0].zoneList),
//                             gridData: FlGridData(show: true),
//                             borderData: FlBorderData(show: true),
//                             barGroups:
//                             buildZoneBarGroups(zones.data[0].zoneList),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//
//               ],
//             ),
//
//           ),
//           const SizedBox(height: 10),
//           const Padding(
//             padding: EdgeInsets.only(left: 8),
//             child: Text(
//               "Zones",
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           _legend(),
//
//           const SizedBox(height: 10),
//
//             Padding(
//             padding: EdgeInsets.only(left: 8),
//             child: Text(
//               "Total Flow (Lts):${zones.totalFlow}",
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           SizedBox(height: 20,),
//
//         ],
//       ),
//     );
//   }
//
//
//   double _calculateMaxY() {
//     double max = 0;
//     for (final z in zones.data) {
//       final v = timeStringToDouble(z.zoneList[0].duration);
//       if (v > max) max = v;
//     }
//     return max + 0.5;
//   }

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
     return zoneList.isEmpty ? noData : Expanded(
      child: Column(
        children: [
           Expanded(
            child: Row(
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      "Hours / Litres",
                      style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: zoneList.length * 120,
                      child: BarChart(
                        BarChartData(
                          maxY: _calculateMaxY(),
                          barTouchData: barTouchData(zoneList),
                          titlesData: zoneBarTitles(zoneList),
                          barGroups: buildZoneBarGroups(zoneList),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),
          _legend(),

          const SizedBox(height: 8),
          Text(
            "Total Flow (Lts): $totalFlow",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  double _calculateMaxY() {
    double max = 0;
    for (final z in zoneList) {
      final v = timeStringToDouble(z.duration);
      if (v > max) max = v;
    }
    return max + 0.5;
  }



  BarTouchData barTouchData(List<ZoneCyclicDetailEntity> zones) {
    return BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
         getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final zone = zones[group.x.toInt()];
          return BarTooltipItem(
            '${zone.duration}',
            const TextStyle(color: Colors.white),
          );
        },
      ),
    );
  }
  List<BarChartGroupData> buildZoneBarGroups(
      List<ZoneCyclicDetailEntity> zones,
      ) {
    return List.generate(zones.length, (index) {
      final zone = zones[index];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: timeStringToDouble(zone.duration), // OR zone.flow
            width: 26,
            color: zoneColor(index),
            borderRadius: BorderRadius.circular(6),

            /// 🔹 TOP VALUE ON BAR
            rodStackItems: [],
          ),
        ],
        showingTooltipIndicators: [0],
      );
    });
  }
  FlTitlesData zoneBarTitles(List<ZoneCyclicDetailEntity> zones) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toStringAsFixed(1),
              style: const TextStyle(fontSize: 10),
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
            if (index < 0 || index >= zones.length) {
              return const SizedBox();
            }

            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                zones[index].zone,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),

      topTitles:
      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles:
      const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }
  Color zoneColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.cyan,
      Colors.lime,
      Colors.pink,
    ];

    return colors[index % colors.length];
  }
  double timeStringToDouble(String time) {
    // "HH:mm:ss"
    final parts = time.split(':');
    final h = double.parse(parts[0]);
    final m = double.parse(parts[1]);
    final s = double.parse(parts[2]);

    return h + (m / 60) + (s / 3600);
  }

  Widget _legend() {
    return Center(
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: zoneList.length,
          itemBuilder: (context, index) {
            final zone = zoneList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // ✅
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: zoneColor(index),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    zoneList[index].zone,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

}
