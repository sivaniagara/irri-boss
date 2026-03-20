import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/common_date_picker.dart';
import '../../../../../core/widgets/glassy_wrapper.dart';
import '../../../../../core/widgets/no_data.dart';
import '../bloc/voltage_bloc.dart';
import '../bloc/voltage_bloc_event.dart';
import '../bloc/voltage_bloc_state.dart';

class VoltageGraphPage extends StatefulWidget {
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
  State<VoltageGraphPage> createState() => _VoltageGraphPageState();
}

class _VoltageGraphPageState extends State<VoltageGraphPage> {
  // 🔹 Zoom & Pan State Variables
  double _minX = 0;
  double _maxX = 10;
  double _lastScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GlassyWrapper(
      child: Scaffold(
        appBar: _appBar(context),
        body: BlocBuilder<VoltageGraphBloc, VoltageGraphState>(
          builder: (context, state) {
            if (state is VoltageGraphLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is VoltageGraphError) {
              return Center(child: Text(state.message, style: const TextStyle(color: Colors.black)));
            }

            if (state is VoltageGraphLoaded) {
              final data = state.data.data;

              if (data.isEmpty) return noDataNew;

              return ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  _graphCard(data),
                  const SizedBox(height: 12),
                  _totalPowerCard(data.last.totalPowerOnTime ?? "0:00"),
                  const SizedBox(height: 12),
                  ...data.map((e) => dataCard(e)),
                ],
              );
            }

            return noDataNew;
          },
        ),
      ),
    );
  }

  /// 🔹 GRAPH CARD WITH GESTURE CONTROL
  Widget _graphCard(List data) {
    const Color rColor = Color(0xFFE21E11);
    const Color yColor = Color(0xFFDAB222);
    const Color bColor = Color(0xFF3B83C5);
    final maxYValue = _getMaxVoltage(data);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    _LegendDot(color: rColor, text: "Red"),
                    SizedBox(width: 12),
                    _LegendDot(color: yColor, text: "Yellow"),
                    SizedBox(width: 12),
                    _LegendDot(color: bColor, text: "Blue"),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _minX = 0;
                    _maxX = 10;
                  }),
                  icon: const Icon(Icons.zoom_out_map, size: 16),
                  label: const Text("Zoom Reset", style: TextStyle(fontSize: 12)),
                )
              ],
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onScaleStart: (details) => _lastScale = 1.0,
              onScaleUpdate: (details) {
                setState(() {
                  // --- ZOOM LOGIC ---
                  double scaleDiff = details.scale - _lastScale;
                  _lastScale = details.scale;
                  _maxX -= scaleDiff * 8.0; // Zoom sensitivity

                  // --- PAN LOGIC ---
                  double delta = -details.focalPointDelta.dx * 0.02; // Pan sensitivity
                  _minX += delta;
                  _maxX += delta;

                  // --- BOUNDARY CHECKS ---
                  if (_maxX - _minX < 3) _maxX = _minX + 3; // Max zoom in
                  if (_minX < 0) {
                    _maxX -= _minX;
                    _minX = 0;
                  }
                  if (_maxX > data.length) {
                    _minX -= (_maxX - data.length);
                    _maxX = data.length.toDouble();
                  }
                });
              },
              child: SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    minX: _minX,
                    maxX: _maxX,
                    minY: 0,
                    maxY: maxYValue,
                    lineTouchData: LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => const Color(0xFF8AC7FF).withValues(alpha: 0.8),
                        maxContentWidth: 120,
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((LineBarSpot touchedSpot) {
                            final int index = touchedSpot.x.toInt();
                            final String time = data[index].time;
                            final bool isFirstBar = touchedSpots.indexOf(touchedSpot) == 0;

                            return LineTooltipItem(
                              '${isFirstBar ? 'Time:$time\n' : ''}${touchedSpot.y.toStringAsFixed(1)} V',
                              TextStyle(
                                color: touchedSpot.bar.color ?? Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    clipData: const FlClipData.all(),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (_) => const FlLine(color: Colors.black12, strokeWidth: 1),
                      getDrawingVerticalLine: (_) => const FlLine(color: Colors.black12, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            int idx = value.toInt();
                            if (idx >= 0 && idx < data.length && idx % 2 == 0) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(data[idx].time, style: const TextStyle(fontSize: 9)),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      _line(data, (d) => double.tryParse(d.r.toString()) ?? 0, rColor),
                      _line(data, (d) => double.tryParse(d.y.toString()) ?? 0, yColor),
                      _line(data, (d) => double.tryParse(d.b.toString()) ?? 0, bColor),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _line(List data, double Function(dynamic) getY, Color color) {
    return LineChartBarData(
      spots: List.generate(data.length, (i) => FlSpot(i.toDouble(), getY(data[i]))),
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: const FlDotData(show: false),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: const Text("VOLTAGE REPORT", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ActionChip(
            label: Text(widget.fromDate),
            onPressed: () async {
              final result = await pickReportDate(context: context, allowRange: false);
              if (result != null && mounted) {
                context.read<VoltageGraphBloc>().add(FetchVoltageGraphEvent(
                      userId: widget.userId,
                      subuserId: widget.subuserId,
                      controllerId: widget.controllerId,
                      fromDate: result.fromDate,
                      toDate: result.toDate,
                    ));
              }
            },
            avatar: const Icon(Icons.calendar_today, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _totalPowerCard(String power) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: const Icon(Icons.flash_on, color: Colors.orange),
        title: Text("Total Power: $power Hours", style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget dataCard(dynamic e) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          timeBox(e.time),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  phaseCard(
                    color: const Color(0xffE53935),
                    r: e.r,
                    ry: e.ry,
                    c: e.c1,
                  ),
                  phaseCard(
                    color: const Color(0xffD4A017),
                    r: e.y,
                    ry: e.ry,
                    c: e.c1,
                  ),
                  phaseCard(
                    color: const Color(0xff3B82C4),
                    r: e.b,
                    ry: e.ry,
                    c: e.c1,
                  ),
                  wellLevelCard(e.wellPercentage, e.wellLevel),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget phaseCard({
    required Color color,
    required dynamic r,
    required dynamic ry,
    required dynamic c,
  }) {
    return Expanded(
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("R $r V", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
              child: Container(
                color: Colors.white,
                height: 0.5,
              ),
            ),
            Text("RY $ry V", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 2, bottom: 2),
              child: Container(
                color: Colors.white,
                height: 0.5,
              ),
            ),
            Text("C1 $c A", style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget wellLevelCard(String percentage, String feet) {
    return Container(
      width: 70,
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffA8D4FF),
            Color(0xff4A90E2),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Well Level",
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
          Text(
            feet,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "$percentage%",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }

  Widget timeBox(String time) {
    return Container(
      width: 70,
      height: 100,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xffBFD1E5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  double _getMaxVoltage(List data) {
    double maxValue = 0;
    for (var d in data) {
      double r = double.tryParse(d.r.toString()) ?? 0;
      double y = double.tryParse(d.y.toString()) ?? 0;
      double b = double.tryParse(d.b.toString()) ?? 0;
      maxValue = [maxValue, r, y, b].reduce(max);
    }
    return maxValue > 0 ? maxValue + 30 : 300;
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendDot({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
