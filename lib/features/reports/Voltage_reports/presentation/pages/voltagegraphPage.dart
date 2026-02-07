


import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_gradients.dart';
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
        body: Container(
          child: BlocBuilder<VoltageGraphBloc, VoltageGraphState>(
            builder: (context, state) {
              if (state is VoltageGraphLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is VoltageGraphError) {
                return Center(child: Text(state.message, style: const TextStyle(color: Colors.black)));
              }

              if (state is VoltageGraphLoaded) {
                final data = state.data.data;

                if (data.isEmpty) return noData;

                return ListView(
                  padding: const EdgeInsets.all(8),
                  children: [
                    _graphCard(data),
                    const SizedBox(height: 12),
                    _totalPowerCard(data.last.totalPowerOnTime ?? "0:00"),
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
                  onPressed: () => setState(() { _minX = 0; _maxX = 10; }),
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
                  if (_minX < 0) { _maxX -= _minX; _minX = 0; }
                  if (_maxX > data.length) { _minX -= (_maxX - data.length); _maxX = data.length.toDouble(); }
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
                        getTooltipColor: (touchedSpot) => Color(0xFF8AC7FF),
                        tooltipRoundedRadius: 8,
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
                      getDrawingHorizontalLine: (_) => FlLine(color: Colors.black12, strokeWidth: 1),
                      getDrawingVerticalLine: (_) => FlLine(color: Colors.black12, strokeWidth: 1),
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


  Widget _dataCard(dynamic e) {
    return Row(
      children: [
        _timeBox(e.time),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(width: 8),

                _phasePill(
                  title: 'R Phase',
                  value: '${e.r} V',
                  color: const Color(0xFFE21E11),
                ),
                _phasePill(
                  title: 'Y Phase',
                  value: '${e.y} V',
                  color: const Color(0xFFDAB222),
                ),
                _phasePill(
                  title: 'B Phase',
                  value: '${e.b} V',
                  color: const Color(0xFF3B83C5),
                ),
                _phasePill(
                  title: 'Well Level',
                  value: '${e.wellPercentage}%',
                  color: const Color(0xFF8AC7FF),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _timeBox(String time) {
    return Container(
      width: 70,
      height: 68,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFDCEEFF),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A73E8),
        ),
      ),
    );
  }

  Widget _phasePill({
    required String title,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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