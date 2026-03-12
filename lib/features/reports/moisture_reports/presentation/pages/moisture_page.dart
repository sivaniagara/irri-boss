import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/theme/app_themes.dart';

import '../../../../../core/widgets/custom_app_bar.dart';
import '../../../../../core/widgets/no_data.dart';
import '../../../../report_downloader/utils/report_downloaderRoute.dart';
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
    return Scaffold(
      backgroundColor: AppThemes.scaffoldBackGround,
      appBar: const CustomAppBar(
        title: "Moisture Reports",
      ),

      floatingActionButton: FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.download, color: Colors.white),
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
    );
  }

}
