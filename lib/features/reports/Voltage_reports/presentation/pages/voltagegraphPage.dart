import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/no_data.dart';
import '../../../../../core/theme/app_gradients.dart';
import '../../../../../core/utils/common_date_picker.dart';
import '../../../../../core/widgets/glassy_wrapper.dart';
import '../bloc/voltage_bloc.dart';
import '../bloc/voltage_bloc_event.dart';
import '../bloc/voltage_bloc_state.dart';

class VoltageGraphPage extends StatelessWidget {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const VoltageGraphPage({
    super.key,
    required this.userId,
    required this.subuserId,
    required this.controllerId,
    required this.fromDate,
    required this.toDate,
  });


  @override
  Widget build(BuildContext context) {
    return GlassyWrapper(
      child: Scaffold(
         appBar: _appBar(context),
        body:Container(
          decoration: BoxDecoration(
            gradient: AppGradients.commonGradient,
          ),
          child: BlocBuilder<VoltageGraphBloc, VoltageGraphState>(
            builder: (context, state) {
              if (state is VoltageGraphLoading) {
                return const Center(child: CircularProgressIndicator());
              }
      
              if (state is VoltageGraphError) {
                return Center(child: Text(state.message,style: TextStyle(color: Colors.black),));
              }
      
              if (state is VoltageGraphLoaded) {
                final data = state.data.data;
      
                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    _graphCard(data),
      
                    const SizedBox(height: 12),
                    _totalPowerCard(
                      data.isNotEmpty
                          ? data.last.totalPowerOnTime
                          : "0:00",
                    ),
                     const SizedBox(height: 12),
                    ...data.map((e) => _dataCard(e)).toList(),
                  ],
                );
              }
      
              return noData;
            },
          ),
        ),
      ),
    );
  }

  /// 🔹 APP BAR
  AppBar _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "VOLTAGE REPORT",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      actions: [
        Row(
          children: [
            Text(fromDate, style: const TextStyle(color: Colors.black)),
            IconButton(
              icon: const Icon(Icons.calendar_today, color: Colors.black),
              onPressed: () async {
                final result = await pickReportDate(
                  context: context,
                  allowRange: false, // 👈 SAME DATE
                );

                if (result == null) return;

                context.read<VoltageGraphBloc>().add(
                  FetchVoltageGraphEvent(
                    userId: userId,
                    subuserId: subuserId,
                    controllerId: controllerId,
                    fromDate: result.fromDate,
                    toDate: result.toDate,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }


  /// 🔹 TOTAL POWER
  Widget _totalPowerCard(String power) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children:  [
            Icon(Icons.flash_on, color: Colors.black),
            SizedBox(width: 8),
            Text(
              "Total Power : ${power} Hours",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 PER HOUR DATA
  Widget _dataCard(dynamic e) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            _timeBox(e.time),
            _phaseBox("R", "RY", e.r,"C1",e.c1,Colors.red),
            _phaseBox("Y", "YB", e.y,"C2",e.c1,Colors.yellow),
            _phaseBox("B", "BR", e.b,"C3",e.c1,Colors.blue),
            _wellLevel(e.wellLevel, e.wellPercentage),
          ],
        ),
      ),
    );
  }

  Widget _timeBox(String time) {
    return Text(
      time,
      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 11),
    );
  }

  Widget _phaseBox(
      String label,
      String pair,
      String value,
      String clabel,
      String cvalue,
      Color color,
      ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dotText(
            color: color,
            text: "$pair $value V",
          ),
          const SizedBox(height: 4),
          _dotText(
            color: color,
            text: "$label $value V",
            bold: true,
          ),
          const SizedBox(height: 4),
          _dotText(
            color: color,
            text: "$clabel $cvalue A",
            fontSize: 12,
          ),
        ],
      ),
    );
  }
  Widget _dotText({
    required Color color,
    required String text,
    bool bold = false,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 2),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
  Widget _wellLevel(String level, String percent) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text("Well Level", style: TextStyle(color: Colors.white)),
          Text("$level F", style: const TextStyle(color: Colors.white)),
          Text("$percent%", style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}



/// 🔹 GRAPH CARD
Widget _graphCard(List data) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            "Voltage",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 150,

                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: Colors.black26, strokeWidth: 1),
                  getDrawingVerticalLine: (_) =>
                      FlLine(color: Colors.black26, strokeWidth: 1),
                ),

                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "${value.toInt()}:00",
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                lineBarsData: [
                  _line(data, (d) => double.parse(d.r), Colors.red),
                  _line(data, (d) => double.parse(d.y), Colors.yellow),
                  _line(data, (d) => double.parse(d.b), Colors.blue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _legend(),
        ],
      ),
    ),
  );
}

/// 🔹 LEGEND
Widget _legend() {
  return Column(
    children: const [
      _LegendRow(color: Colors.red, text: "R-Voltage"),
      _LegendRow(color: Colors.yellow, text: "Y-Voltage"),
      _LegendRow(color: Colors.blue, text: "B-Voltage"),
      SizedBox(height: 6),
      Text(
        "X - Hours     Y - Voltage",
        style: TextStyle(fontSize: 12, color: Colors.black),
      ),
    ],
  );
}
LineChartBarData _line(
    List data,
    double Function(dynamic) getY,
    Color color,
    ) {
  return LineChartBarData(
    spots: List.generate(
      data.length,
          (i) => FlSpot(i.toDouble(), getY(data[i])),
    ),
    isCurved: true,
    color: color,
    barWidth: 2.5,
    dotData: FlDotData(show: false),
    // dotData: FlDotData(
    //   show: true,
    //   getDotPainter: (spot, percent, bar, index) {
    //     return FlDotCirclePainter(
    //       radius: 3.5,
    //       color: color,
    //       strokeWidth: 1,
    //       strokeColor: Colors.black,
    //     );
    //   },
    // ),
  );
}

/// 🔹 LEGEND ROW
class _LegendRow extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendRow({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 10, color: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.black)),
      ],
    );
  }
}
