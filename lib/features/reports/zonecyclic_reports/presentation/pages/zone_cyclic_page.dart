
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/presentation/pages/zone_cyclic_graph.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/presentation/pages/zone_cyclic_reports.dart';

import '../../../../../core/utils/common_date_picker.dart';
import '../../../../../core/widgets/no_data.dart';
import '../../../../report_downloader/utils/report_downloaderRoute.dart';
import '../../domain/entities/zone_cyclic_entities.dart';
import '../bloc/zone_cyclic_bloc.dart';
import '../bloc/zone_cyclic_bloc_event.dart';
import '../bloc/zone_cyclic_bloc_state.dart';
import '../bloc/zone_cyclic_mode.dart';

class ZoneCyclicPage extends StatelessWidget {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const ZoneCyclicPage({
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
        title: const Text("Zone Cyclic Status"),
        actions: [
          /// 🔹 Toggle View (Cubit → View State)
          BlocBuilder<ZoneCyclicCubit, TdyValveViewState>(
            builder: (context, viewState) {
              return IconButton(
                icon: Icon(
                  viewState.viewMode == ZoneCyclicViewMode.zoneStatus
                      ? Icons.bar_chart
                      : Icons.list_alt,
                ),
                onPressed: () {
                  context.read<ZoneCyclicCubit>().toggleView();
                  final program =
                  (viewState.selectedProgramIndex + 1).toString();
                  context.read<ZoneCyclicBloc>().add(
                    FetchZoneCyclicEvent(
                      userId: userId,
                      subuserId: subuserId,
                      controllerId: controllerId,
                      fromDate: fromDate,
                      toDate: viewState.viewMode == ZoneCyclicViewMode.zoneStatus ? toDate : fromDate,
                    ),
                  );
                },
              );
            },
          ),
          BlocBuilder<ZoneCyclicCubit, TdyValveViewState>(
            builder: (_, viewState) {
              return IconButton(
                icon: const Icon(Icons.calendar_today,
                    color: Colors.black),
                onPressed: () async {
                  final result = await pickReportDate(
                    context: context,
                    allowRange: viewState.viewMode == ZoneCyclicViewMode.zoneStatus ? true :false,
                  );
                  if (result == null) return;

                  context.read<ZoneCyclicBloc>().add(
                    FetchZoneCyclicEvent(
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
         ],
      ),
       /// 🔹 BODY → Bloc State (API)
      body: BlocBuilder<ZoneCyclicBloc, ZoneCyclicState>(
        builder: (context, state) {
          if (state is ZoneCyclicLoading) {
            return const Center(child: CircularProgressIndicator());
          }
           if (state is ZoneCyclicError) {

            return Column(
              children: [
                _programDropdown(context),
                noData,
              ],
            );
          }

          if (state is ZoneCyclicLoaded) {
            return Column(
              children: [
                BlocBuilder<ZoneCyclicCubit, TdyValveViewState>(
                  builder: (context, viewState) {
                    return   viewState.viewMode == ZoneCyclicViewMode.zoneStatus ? SizedBox() : _programDropdown(context);
                  },
                ),
                 const SizedBox(height: 12),

                BlocBuilder<ZoneCyclicCubit, TdyValveViewState>(
          builder: (context, viewState) {
            final selectedProgram = (viewState.selectedProgramIndex + 1).toString();


            final matchingPrograms = state.data.data
                .where((e) => e.program == selectedProgram)
                .toList();

            final selectedProgramZones =
            matchingPrograms.isNotEmpty ? matchingPrograms.first.zoneList : <ZoneCyclicDetailEntity>[];


            return viewState.viewMode == ZoneCyclicViewMode.zoneStatus ? ZoneCyclicPageReport(data: state.data) : ZoneCyclicGraph(
            zoneList: selectedProgramZones,
            totalFlow: state.data.totalFlow,
          );
          },
          ),
               ],
            );
          }
          return noData;
        },
      ),
    );
  }
   // 🔹 PROGRAM DROPDOWN
  Widget _programDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<int>(
        value: context.watch<ZoneCyclicCubit>().state.selectedProgramIndex,
        decoration: const InputDecoration(
          labelText: "Select Program",
          border: OutlineInputBorder(),
        ),
        items: List.generate(
          6,
              (index) => DropdownMenuItem(
            value: index,
            child: Text("Program ${index + 1}"),
          ),
        ),
        onChanged: (index) {
          if (index == null) return;

          final cubit = context.read<ZoneCyclicCubit>();
          cubit.selectProgram(index);

          final program = (index + 1).toString();

          context.read<ZoneCyclicBloc>().add(
            FetchZoneCyclicEvent(
              userId: userId,
              subuserId: subuserId,
              controllerId: controllerId,
              fromDate: fromDate,
              toDate: toDate,
            ),
          );
        },
      ),
    );
  }
   // 🔹 ZONE CARD
  Widget _zoneCard(dynamic item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.zone,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _infoRow("Place", item.zonePlace),
            _infoRow("Duration", item.duration),
            _infoRow("Litres", "${item.litres} L"),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }


}


