
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/no_data.dart';

import '../../../../../core/utils/common_date_picker.dart';
 import '../../../../report_downloader/utils/report_downloaderRoute.dart';
import '../../utils/motor_cyclic_routes.dart';
import '../bloc/motor_cyclic_bloc.dart';
import '../bloc/motor_cyclic_bloc_event.dart';
import '../bloc/motor_cyclic_bloc_state.dart';
import '../bloc/motor_cyclic_mode.dart';
import 'motor_cyclic_zone_status_page.dart';
import 'motor_cyclic_zone_status_report.dart';

class MotorCyclicPage extends StatelessWidget {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const MotorCyclicPage({
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
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),

        // 🔹 TITLE CHANGE
        title: BlocBuilder<MotorCyclicViewCubit, MotorCyclicViewState>(
          builder: (_, viewState) {
            return Text(
              viewState.viewMode == MotorCyclicViewMode.zoneStatus
                  ? "ZONE STATUS"
                  : "MOTOR CYCLIC REPORT",
            );
          },
        ),

        actions: [
          // 🔹 GRID / LIST TOGGLE
          // BlocBuilder<MotorCyclicViewCubit, MotorCyclicViewState>(
          //   builder: (_, viewState) {
          //     return IconButton(
          //       icon: Icon(
          //         viewState.viewMode == MotorCyclicViewMode.zoneStatus
          //             ? Icons.list_alt_outlined
          //             : Icons.grid_view_outlined,
          //         color: Colors.black,
          //       ),
          //       onPressed: () {
          //         context
          //             .read<MotorCyclicViewCubit>()
          //             .toggleView();
          //       },
          //     );
          //   },
          // ),
          BlocBuilder<MotorCyclicViewCubit, MotorCyclicViewState>(
            builder: (context, viewState) {
              return IconButton(
                icon: Icon(
                  viewState.viewMode == MotorCyclicViewMode.zoneStatus
                      ? Icons.list_alt_outlined
                      : Icons.grid_view_outlined,
                  color: Colors.black,
                ),
                onPressed: () {
                  final viewCubit =
                  context.read<MotorCyclicViewCubit>();
                  final currentMode = viewCubit.state.viewMode;

                  viewCubit.toggleView();

                  // 🔹 When switching TO ZONE STATUS → reload with TODAY
                  if (currentMode !=
                      MotorCyclicViewMode.zoneStatus) {
                    final today = _today();
                    context.read<MotorCyclicBloc>().add(
                      FetchMotorCyclicEvent(
                        userId: userId,
                        subuserId: subuserId,
                        controllerId: controllerId,
                        fromDate: today,
                        toDate: today,
                      ),
                    );
                  }
                },
              );
            },
          ),

          BlocBuilder<MotorCyclicViewCubit, MotorCyclicViewState>(
            builder: (_, viewState) {
              return IconButton(
                icon: const Icon(Icons.calendar_today,
                    color: Colors.black),
                onPressed: () async {
                  final result = await pickReportDate(
                    context: context,
                    allowRange: viewState.viewMode == MotorCyclicViewMode.zoneStatus ? false :true,
                  );
                  if (result == null) return;

                  context.read<MotorCyclicBloc>().add(
                    FetchMotorCyclicEvent(
                      userId: userId,
                      subuserId: subuserId,
                      controllerId: controllerId,
                      fromDate: result.fromDate,
                      toDate: result.toDate,
                    ),
                  );
                },
              ) ;
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
              "url": MotorCyclicPageUrls.getMotorCyclicUrl,
            },
          );
        },
      ),

      // 🔹 BODY
      body: BlocBuilder<MotorCyclicBloc, MotorCyclicState>(
        builder: (context, state) {
          if (state is MotorCyclicLoading) {
            return const Center(
                child: CircularProgressIndicator());
          }

          if (state is MotorCyclicError) {
            return noData;
          }

          if (state is MotorCyclicLoaded) {
            return BlocBuilder<MotorCyclicViewCubit,
                MotorCyclicViewState>(
              builder: (_, viewState) {
                return viewState.viewMode ==
                    MotorCyclicViewMode.zoneStatus
                    ? MotorCyclicZoneStatusView(
                  data: state.data,
                )
                    : MotorCyclicPageReport(
                  data: state.data,
                );
              },
            );
          }

          return noData;
        },
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
