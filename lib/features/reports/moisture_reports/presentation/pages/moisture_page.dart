
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

 import '../../../../../core/widgets/glassy_wrapper.dart';
import '../../../../../core/widgets/no_data.dart';
import '../../../../report_downloader/utils/report_downloaderRoute.dart';
 import '../../utils/moisture_routes.dart';
import '../bloc/moisture_bloc.dart';
 import '../bloc/moisture_bloc_state.dart';
import 'moisture_status_page.dart';


class MoistureReportPage extends StatelessWidget {
  final int userId;
  final int subuserId;
  final int controllerId;

  const MoistureReportPage({
    super.key,
    required this.userId,
    required this.subuserId,
    required this.controllerId,
   });

  @override
  Widget build(BuildContext context) {
    return GlassyWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Moisture Reports"),
        ),

        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.data_thresholding_sharp),
          onPressed: () {
            context.push(
              ReportDownloadPageRoutes.ReportDownloadPage,
              extra: {
                "title": "Moisture Report",
                "url": MoistureReportPageUrls.getMoistureUrl,
              },
            );
          },
        ),

        // 🔹 BODY
        body: BlocBuilder<MoistureBloc, MoistureState>(
          builder: (context, state) {
            if (state is MoistureLoading) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            if (state is MoistureError) {
              return noData;
            }

            if (state is MoistureLoaded) {
              return MoistureZoneStatusView(
                data: state.data.data ,);
             }
             return noData;
          },
        ),
      ),
    );
  }

}
