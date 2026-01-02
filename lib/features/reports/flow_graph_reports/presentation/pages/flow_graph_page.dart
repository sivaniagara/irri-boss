
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_gradients.dart';
import '../../../../../core/theme/app_themes.dart';
import '../../../../../core/utils/common_date_picker.dart';
import '../../../../../core/widgets/glassy_wrapper.dart';
import '../../../../../core/widgets/no_data.dart';
import '../../domain/entities/flow_graph_entities.dart';
import '../bloc/flow_graph_bloc.dart';
import '../bloc/flow_graph_bloc_event.dart';
import '../bloc/flow_graph_bloc_state.dart';
import 'flow_graph_chart.dart';

class FlowGraphPage extends StatelessWidget {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const FlowGraphPage({
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
        appBar: AppBar(
          title: const Text("FLOW GRAPH"),
          actions: [
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final result = await pickReportDate(
                  context: context,
                  allowRange: true,
                );
                if (result == null) return;
      
                context.read<FlowGraphBloc>().add(
                  FetchFlowGraphEvent(
                    userId: userId,
                    subuserId: subuserId,
                    controllerId: controllerId,
                    fromDate: result.fromDate,
                    toDate: result.toDate,
                  ),
                );
              },
            )
          ],
        ),
      
        /// 🔹 BODY
        body: BlocBuilder<FlowGraphBloc, FlowGraphState>(
          builder: (context, state) {
            if (state is FlowGraphLoading) {
              return const Center(child: CircularProgressIndicator());
            }
      
            if (state is FlowGraphError) {
              return Center(child: Text(state.message));
            }
      
            if (state is FlowGraphLoaded) {
              final list = state.data.data;
      
              if (list.isEmpty) return noData;
      
              final totalFlow = list.fold<double>(
                0,
                    (sum, e) =>
                sum + (double.tryParse(e.totalFlow ?? '0') ?? 0),
              );
      
              final totalRunTimeSeconds = list.fold<int>(
                0,
                    (sum, e) => sum + parseTimeToSeconds(e.totalRunTime),
              );
      
              return ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  /// GRAPH PLACEHOLDER
      
                  SizedBox(
                    height: 220,
                    child: FlowBarChart(list),
                  ),
      
                  const SizedBox(height: 12),
      
                  /// SUMMARY
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(gradient: AppGradients.commonGradient,) ,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        summaryItem(
                          "Total Flow (L)",
                          totalFlow.toStringAsFixed(0),
                        ),
                        summaryItem(
                          "Run Time (H)",
                          (totalRunTimeSeconds / 3600)
                              .toStringAsFixed(1),
                        ),
                      ],
                    ),
                  ),
      
                  const SizedBox(height: 12),
                  /// TABLE
                  Container(
                    decoration: BoxDecoration(gradient: AppGradients.commonGradient,) ,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        children: [
                          tableHeader(),
                          ...list.map(tableRow),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
      
            return noData;
          },
        ),
      ),
    );
  }
}

/// 🔹 Helpers

int parseTimeToSeconds(String? time) {
  if (time == null || !time.contains(':')) return 0;
  final parts = time.split(':').map(int.parse).toList();
  return parts[0] * 3600 + parts[1] * 60 + parts[2];
}

Widget summaryItem(String title, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title),
      Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  );
}

Widget tableHeader() {
  return Container(
    color: Colors.blue,
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: const Row(
      children: [
        HeaderCell("Date"),
        HeaderCell("Run Time\n(hh:mm:ss)"),
        HeaderCell("Total Flow\n(L)"),
        HeaderCell("Power On\nTime"),
      ],
    ),
  );
}

Widget tableRow(FlowGraphDataEntity e) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppThemes.primaryColor,),
    ),
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Cell(e.date ?? '-'),
        Cell(e.totalRunTime ?? '00:00:00'),
        Cell(e.totalFlow ?? '0'),
        Cell(e.totalPowerOnTime ?? '00:00:00'),
      ],
    ),
  );
}

class HeaderCell extends StatelessWidget {
  final String text;
  const HeaderCell(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class Cell extends StatelessWidget {
  final String text;
  const Cell(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      child: Text(
        text,
        textAlign: TextAlign.center,
      ),
    );
  }
}


