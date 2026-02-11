
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import '../../../../../core/theme/app_themes.dart';
import '../../../../../core/utils/app_images.dart';
import '../../../../../core/utils/common_date_picker.dart';
import '../../../../../core/widgets/glassy_wrapper.dart';
import '../../../../../core/widgets/no_data.dart';
import '../../domain/entities/flow_graph_entities.dart';
import '../bloc/flow_graph_bloc.dart';
import '../bloc/flow_graph_bloc_event.dart';
import '../bloc/flow_graph_bloc_state.dart';
import 'flow_graph_chart.dart';

class FlowGraphPage extends StatefulWidget {
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
  State<FlowGraphPage> createState() => _FlowGraphPageState();
}

class _FlowGraphPageState extends State<FlowGraphPage> {
  int _selectedSegment = 2; // Default to 'Monthly' based on image

  @override
  Widget build(BuildContext context) {
    return GlassyWrapper(
      child: Scaffold(
        backgroundColor: AppThemes.scaffoldBackGround,
        appBar: AppBar(
          title: const Text("Flow Report Data"),
          actions: [
            BlocBuilder<FlowGraphBloc, FlowGraphState>(
              builder: (context, state) {
                return IconButton(
                  icon: Image.asset(AppImages.downloadIcon, width: 22, height: 22),
                  onPressed: () {
                    if (state is FlowGraphLoaded && state.data.data.isNotEmpty) {
                      context.push('/ReportDownload', extra: {
                        'title': 'Flow Report',
                        'data': state.data.data.map((e) => e.toJson()).toList(),
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("No data available to download")),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocBuilder<FlowGraphBloc, FlowGraphState>(
          builder: (context, state) {
            if (state is FlowGraphLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is FlowGraphError) {
              return Column(
                children: [
                  _buildTopControls(context, widget.fromDate, widget.toDate),
                  Expanded(child: Center(child: Text(state.message))),
                ],
              );
            }

            if (state is FlowGraphLoaded) {
              final list = state.data.data;

              if (list.isEmpty) {
                return Column(
                  children: [
                    _buildTopControls(context, state.fromDate, state.toDate),
                    Expanded(child: noDataNew),
                  ],
                );
              }
              
              final totalFlow = list.fold<double>(
                0, (sum, e) => sum + (double.tryParse(e.totalFlow ?? '0') ?? 0),
              );

              final totalRunTimeSeconds = list.fold<int>(
                0, (sum, e) => sum + parseTimeToSeconds(e.totalRunTime),
              );

              return Column(
                children: [
                  _buildTopControls(context, state.fromDate, state.toDate),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        const SizedBox(height: 12),
                        // Chart Container
                        Container(
                          height: 300,
                          padding: const EdgeInsets.only(top: 20, right: 16, left: 8, bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: FlowBarChart(list),
                        ),
                        const SizedBox(height: 16),
                        // Summary Row
                        Row(
                          children: [
                            Expanded(
                              child: _summaryCard(
                                "Total Flow :",
                                "${totalFlow.toInt()}",
                                " L",
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _summaryCard(
                                "Total Run Time :",
                                "${(totalRunTimeSeconds / 3600).toInt()}",
                                " H",
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Data Table
                        if (list.isNotEmpty) _buildDataTable(list),
                        const SizedBox(height: 80), // Space for bottom bar
                      ],
                    ),
                  ),
                ],
              );
            }
            return noDataNew;
          },
        ),
      ),
    );
  }

  Widget _buildTopControls(BuildContext context, String currentFrom, String currentTo) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Segmented Control
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CupertinoSlidingSegmentedControl<int>(
              backgroundColor: Colors.transparent,
              thumbColor: AppThemes.primaryColor,
              groupValue: _selectedSegment,
              children: {
                0: _segmentText("Days", _selectedSegment == 0),
                1: _segmentText("Weekly", _selectedSegment == 1),
                2: _segmentText("Monthly", _selectedSegment == 2),
              },
              onValueChanged: (value) {
                if (value != null) setState(() => _selectedSegment = value);
              },
            ),
          ),
          const SizedBox(height: 16),
          // Date Range Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("From", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              _dateBox(context, currentFrom, isFrom: true),
              const SizedBox(width: 12),
              const Text("To", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              _dateBox(context, currentTo, isFrom: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _segmentText(String text, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _dateBox(BuildContext context, String date, {required bool isFrom}) {
    return GestureDetector(
      onTap: () async {
        final result = await pickReportDate(context: context, allowRange: true);
        if (result == null) return;
        if (!context.mounted) return;
        context.read<FlowGraphBloc>().add(
          FetchFlowGraphEvent(
            userId: widget.userId,
            subuserId: widget.subuserId,
            controllerId: widget.controllerId,
            fromDate: result.fromDate,
            toDate: result.toDate,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppThemes.secondaryColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppThemes.secondaryColor),
        ),
        child: Text(
          date,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 13),
          children: [
            TextSpan(text: label, style: const TextStyle(color: Colors.black54)),
            TextSpan(
              text: " $value",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppThemes.primaryColor),
            ),
            TextSpan(text: unit, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildDataTable(List<FlowGraphDataEntity> list) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(2.5),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(2.5),
            3: FlexColumnWidth(1.5),
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey[100]!, width: 1),
            verticalInside: BorderSide(color: Colors.grey[100]!, width: 1),
          ),
          children: [
            // Header
            TableRow(
              decoration: BoxDecoration(color: AppThemes.primaryColor),
              children: [
                _tableHeaderCell("Date"),
                _tableHeaderCell("Run Time"),
                _tableHeaderCell("Total Flow"),
                _tableHeaderCell("Power"),
              ],
            ),
            // Rows
            ...list.map((e) => TableRow(
              children: [
                _tableCell(e.date ?? '-', isBold: true, color: const Color(0xFF00796B)),
                _tableCell(e.totalRunTime ?? '00:00:00'),
                _tableCell("${e.totalFlow ?? '0'} L"),
                _tableCell(e.totalPowerOnTime?.split(':').first ?? '0'),
              ],
            )),
          ],
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _tableCell(String text, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color ?? Colors.black87,
        ),
      ),
    );
  }
}

int parseTimeToSeconds(String? time) {
  if (time == null || !time.contains(':')) return 0;
  try {
    final parts = time.split(':').map(int.parse).toList();
    if (parts.length == 3) {
      return parts[0] * 3600 + parts[1] * 60 + parts[2];
    } else if (parts.length == 2) {
      return parts[0] * 3600 + parts[1] * 60;
    }
  } catch (e) {
    // Optionally log the error
  }
  return 0;
}
