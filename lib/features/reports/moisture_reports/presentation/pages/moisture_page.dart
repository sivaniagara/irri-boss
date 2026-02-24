
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
              final state = context.read<MoistureBloc>().state;

              if (state is MoistureLoaded) {
                final List<Map<String, dynamic>> excelData =
                state.data.data.mostList.map((e) => e.toJson()).toList();
                context.push(
                  ReportDownloadPageRoutes.ReportDownloadPage,
                  extra: {
                    "title": "Moisture REPORT",
                    "data": excelData,
                  },
                );
              }
            }
        ),

        // 🔹 BODY
        body: BlocBuilder<MoistureBloc, MoistureState>(
          builder: (context, state) {
            if (state is MoistureLoading) {
              return const Center(
                  child: CircularProgressIndicator());
            }

            if (state is MoistureError) {
              return noDataNew;
            }

            if (state is MoistureLoaded) {
              return MoistureZoneStatusView(
                data: state.data.data ,);
             }
             return noDataNew;
          },
        ),
      ),
    );
  }

}
