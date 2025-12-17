import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/common_date_picker.dart';
import '../bloc/power_bloc.dart';
import '../bloc/power_bloc_event.dart';
import '../bloc/power_bloc_state.dart';

class PowerGraphPage extends StatelessWidget {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const PowerGraphPage({
    super.key,
    required this.userId,
    required this.subuserId,
    required this.controllerId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF6FF),
      appBar: _appBar(context),
      body: BlocBuilder<PowerGraphBloc, PowerGraphState>(
        builder: (context, state) {
          if (state is PowerGraphLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PowerGraphError) {
            return Center(child: Text(state.message));
          }

          if (state is PowerGraphLoaded) {
            final data = state.data;

            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _dateTabs(context),
                const SizedBox(height: 10),
                _barAndPieCard(data),
                const SizedBox(height: 12),
                _powerDetails(data),
                const SizedBox(height: 12),
                _flowDetails(data),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  // 🔹 APP BAR
  AppBar _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F7EC7),
      title: const Text("POWER AND MOTOR"),
      leading: const BackButton(color: Colors.white),
    );
  }

  // 🔹 DAY / WEEKLY / MONTHLY + DATE PICKER
  Widget _dateTabs(BuildContext context) {
    return Row(
      children: [
        _tab("Days", true),
        _tab("Weekly", false),
        _tab("Monthly", false),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final result = await pickReportDate(
              context: context,
              allowRange: true,
            );

            if (result == null) return;

            context.read<PowerGraphBloc>().add(
              FetchPowerGraphEvent(userId: userId, subuserId: subuserId, controllerId: controllerId, fromDate: fromDate, toDate: toDate));
          },
        ),
      ],
    );
  }

  Widget _tab(String text, bool active) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 BAR + PIE
  Widget _barAndPieCard(PowerReport data) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Hours", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  maxY: data.maxHour,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: data.powerOnHours,
                          color: Colors.cyan,
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: data.motorRunHours,
                          color: Colors.green,
                        ),
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(show: false),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: data.motorRunPercent,
                      color: Colors.green,
                      title: data.motorRunPercent.toString(),
                    ),
                    PieChartSectionData(
                      value: data.powerIdlePercent,
                      color: Colors.cyan,
                      title: data.powerIdlePercent.toString(),
                    ),
                  ],
                  centerSpaceRadius: 40,
                ),
              ),
            ),

            const SizedBox(height: 8),
            _legend(),
          ],
        ),
      ),
    );
  }

  Widget _legend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _LegendDot(color: Colors.green, text: "Motor Status"),
        SizedBox(width: 16),
        _LegendDot(color: Colors.cyan, text: "Power Status"),
      ],
    );
  }

  // 🔹 POWER DETAILS
  Widget _powerDetails(PowerReport d) {
    return Card(
      child: Column(
        children: [
          _RowItem("Power On Time", d.powerOnTime, Colors.green),
          _RowItem("Power Off Time", d.powerOffTime, Colors.red),
          _RowItem("Motor Run Time", d.motorRunTime, Colors.green),
          _RowItem("Motor Idle Time", d.motorIdleTime, Colors.red),
          _RowItem("Dry Run Time", d.dryRunTime, Colors.red),
        ],
      ),
    );
  }

  // 🔹 FLOW DETAILS
  Widget _flowDetails(PowerReport d) {
    return Card(
      child: Column(
        children: [
          _RowItem("Total Flow", d.totalFlow, Colors.red, unit: "Liters"),
          _RowItem("Cumulative Flow", d.cumulativeFlow, Colors.red, unit: "Liters"),
          _RowItem("Average Flow Rate", d.avgFlowRate, Colors.red, unit: "L/s"),
        ],
      ),
    );
  }
}

/// 🔹 COMMON ROW
class _RowItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String unit;

  const _RowItem(this.label, this.value, this.color, {this.unit = "Hours"});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Text(unit),
        ],
      ),
    );
  }
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
        Text(text),
      ],
    );
  }
}
