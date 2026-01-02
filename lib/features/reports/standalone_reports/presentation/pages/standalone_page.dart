
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/standalone_reports/presentation/pages/standalone_status_page.dart';

import '../../../../../core/utils/common_date_picker.dart';
import '../../../../../core/widgets/glassy_wrapper.dart';
import '../../../../../core/widgets/no_data.dart';
import '../../../../report_downloader/utils/report_downloaderRoute.dart';
import '../../utils/standalone_report_routes.dart';
import '../bloc/standalone_bloc.dart';
import '../bloc/standalone_bloc_event.dart';
import '../bloc/standalone_bloc_state.dart';


class StandaloneReportPage extends StatelessWidget {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const StandaloneReportPage({
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
          title: Text("StandAlone Reports"),
           actions: [

            IconButton(
              icon: const Icon(Icons.calendar_today,
                  color: Colors.black),
              onPressed: () async {
                final result = await pickReportDate(
                  context: context,
                  allowRange: false,
                );
                if (result == null) return;

                context.read<StandaloneBloc>().add(
                  FetchStandaloneEvent(
                    userId: userId,
                    subuserId: subuserId,
                    controllerId: controllerId,
                    fromDate: result.fromDate,
                    toDate: result.toDate,
                  ),
                );
              },
            )
            // 🔹 DATE PICKER
          ],
        ),

        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.data_thresholding_sharp),
          onPressed: () {
            context.push(
              ReportDownloadPageRoutes.ReportDownloadPage,
              extra: {
                "title": "Stand Alone Report",
                "url": StandaloneReportPageUrls.getStandaloneUrl,
              },
            );
          },
        ),

        // 🔹 BODY
        body: BlocBuilder<StandaloneBloc, StandaloneState>(
          builder: (context, state) {
            if (state is StandaloneLoading) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            if (state is StandaloneError) {
              return noData;
            }

            if (state is StandaloneLoaded) {
              return StandaloneZoneStatusView(
                data: state.data,);
             }
             return noData;
          },
        ),
      ),
    );
  }
  String _today() {
    final now = DateTime.now();
    return "${now.year}-"
        "${now.month.toString().padLeft(2, '0')}-"
        "${now.day.toString().padLeft(2, '0')}";
  }
}
