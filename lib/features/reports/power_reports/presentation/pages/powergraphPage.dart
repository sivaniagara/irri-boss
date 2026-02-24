import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/api_urls.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/no_data.dart';
import '../../../../../../core/theme/app_gradients.dart';
import '../../../../../core/utils/common_date_picker.dart';
import '../../../../../core/widgets/glassy_wrapper.dart';
import '../../../../report_downloader/utils/report_downloaderRoute.dart';
import '../../utils/Power_routes.dart';
import '../bloc/date_tab_cubit.dart';
import '../bloc/power_bloc.dart';
import '../bloc/power_bloc_event.dart';
import '../bloc/power_bloc_state.dart';
import '../widgets/barpie_chart.dart';
import '../widgets/power_details_card.dart';
import '../widgets/powergraph_date_tabs.dart';

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

  final int modelId = 7;
  final DateTabType selectedTab = DateTabType.days;

  @override
  Widget build(BuildContext context) {
    return GlassyWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("POWER AND MOTOR"),
          actions: [
            Row(
              children: [
                Text(fromDate, style: const TextStyle(color: Colors.black)),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.black),
                  onPressed: () async {
                    final result = await pickReportDate(
                      context: context,
                      allowRange: true, // 👈 SAME DATE
                    );

                    if (result == null) return;

                    context.read<PowerGraphBloc>().add(
                      FetchPowerGraphEvent(
                        userId: userId,
                        subuserId: subuserId,
                        controllerId: controllerId,
                        fromDate: result.fromDate,
                        toDate: result.toDate, sum: 0,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.data_thresholding_sharp),
            onPressed: () {
              final state = context.read<PowerGraphBloc>().state;

              if (state is PowerGraphLoaded) {
                final List<Map<String, dynamic>> excelData =
                state.data.data.map((e) => e.toJson()).toList();

                context.push(
                  ReportDownloadPageRoutes.ReportDownloadPage,
                  extra: {
                    "title": "Power Motor Report",
                    "data": excelData,
                  },
                );
              }
            }
        ),
        body: Container(

          child: BlocBuilder<PowerGraphBloc, PowerGraphState>(
            builder: (context, state) {
              if (state is PowerGraphLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is PowerGraphError) {
                return Center(
                    child: Text(
                  state.message,
                  style: TextStyle(color: Colors.black),
                ));
              }
              if (state is PowerGraphLoaded) {
                return Column(
                  children: [

                    const SizedBox(height: 8),
                    /// ✅ LIST OF DATA
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: state.data.data.length,
                        itemBuilder: (context, index) {
                          final d = state.data.data[index];
                          return Column(
                            children: [
                              BarPieCard(
                                data: d,
                                modelId: modelId,
                              ),
                              const SizedBox(height: 12),
                              PowerDetailsCard(
                                data: d,
                                modelId: modelId,
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              return noDataNew;
            },
          ),
        ),
      ),
    );
  }
}
