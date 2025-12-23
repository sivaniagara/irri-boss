import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../core/theme/app_gradients.dart';
import '../../../../report_downloader/utils/report_downloaderRoute.dart';
import '../../utils/Power_routes.dart';
import '../bloc/date_tab_cubit.dart';
import '../bloc/power_bloc.dart';
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
    return Scaffold(
       appBar: AppBar(
        title: const Text("POWER AND MOTOR"),
        leading: const BackButton(color: Colors.white),
      ),

      floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.data_thresholding_sharp),
      onPressed: () {
        context.push(ReportDownloadPageRoutes.ReportDownloadPage,extra:{"title":"Power Motor Report","url": '${PowerGraphPageUrls.getPowerGraphUrl}' ,});
        },

    ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.commonGradient,
        ),
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
                  /// ✅ DATE FILTER (ONLY ONCE)
                  DateTabs(
                    userId: userId,
                    subuserId: subuserId,
                    controllerId: controllerId,
                    // selectedTab: selectedTab,
                  ),
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
            return Center(child: Image.asset("assets/images/common/nodata.png",width: 60,height: 60,),);
          },
        ),
      ),
    );
  }
}
