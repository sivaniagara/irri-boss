
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/no_data.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zone_duration_reports/presentation/pages/zone_duration_view.dart';

import '../../../../../core/utils/common_date_picker.dart';
 import '../../../../../core/widgets/glassy_wrapper.dart';
import '../../../../report_downloader/utils/report_downloaderRoute.dart';
import '../../utils/zone_duration_routes.dart';
import '../bloc/zone_duration_bloc.dart';
import '../bloc/zone_duration_bloc_event.dart';
import '../bloc/zone_duration_bloc_state.dart';


class ZoneDurationPage extends StatelessWidget {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const ZoneDurationPage({
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
           // 🔹 TITLE CHANGE
          title: Text("ZONE DURATION REPORT"),
            actions: [
            // 🔹 GRID / LIST TOGGLE
             IconButton(
              icon: const Icon(Icons.calendar_today,
                  color: Colors.black),
              onPressed: () async {
                final result = await pickReportDate(
                  context: context,
                  allowRange:  false,
                );
                if (result == null) return;

                context.read<ZoneDurationBloc>().add(
                  FetchZoneDurationEvent(
                    userId: userId,
                    subuserId: subuserId,
                    controllerId: controllerId,
                    fromDate: result.fromDate,
                    toDate: result.toDate,
                  ),
                );
              },
            ),
            // 🔹 DATE PICKER
          ],
        ),

        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.data_thresholding_sharp),
          onPressed: () {
            context.push(
              ReportDownloadPageRoutes.ReportDownloadPage,
              extra: {
                "title": "Motor Cyclic Report",
                "url": ZoneDurationPageUrls.getZoneDurationUrl,
              },
            );
          },
        ),

        // 🔹 BODY
        body: BlocBuilder<ZoneDurationBloc, ZoneDurationState>(
          builder: (context, state) {
            if (state is ZoneDurationLoading) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            if (state is ZoneDurationError) {
              return Center(child: Text(state.message));
            }

            if (state is ZoneDurationLoaded) {
              return  ZoneDurationPageReport(data: state.data);
            }

            return noData;
          },
        ),
      ),
    );
  }

}
