
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/tdy_valve_status_reports/presentation/pages/tdy_valve_status_graph.dart';

import '../../../../../core/utils/common_date_picker.dart';
import '../../../../../core/widgets/glassy_wrapper.dart';
import '../../../../../core/widgets/no_data.dart';
import '../../../../report_downloader/utils/report_downloaderRoute.dart';
import '../../utils/tdy_valve_status_routes.dart';
import '../bloc/tdy_valve_mode.dart';
 import '../bloc/tdy_valve_status_bloc.dart';
import '../bloc/tdy_valve_status_bloc_event.dart';
import '../bloc/tdy_valve_status_bloc_state.dart';
import '../widgets/tdy_valve_status_card.dart';



class TdyValveStatusPage extends StatelessWidget {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;

  const TdyValveStatusPage({
    super.key,
    required this.userId,
    required this.subuserId,
    required this.controllerId,
    required this.fromDate,
    required String program,
  });

  @override
  Widget build(BuildContext context) {
    return GlassyWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Today Valve Status"),
          actions: [
      
            /// 🔹 Toggle View (Cubit → View State)
            BlocBuilder<TdyValveStatusCubit, TdyValveViewState>(
              builder: (context, viewState) {
                return IconButton(
                  icon: Icon(
                    viewState.viewMode == TdyValveStatusViewMode.zoneStatus
                        ? Icons.bar_chart
                        : Icons.list_alt,
                  ),
                  onPressed: () {
                    context.read<TdyValveStatusCubit>().toggleView();
      
                    final program =
                    (viewState.selectedProgramIndex + 1).toString();
                    context.read<TdyValveStatusBloc>().add(
                      FetchTdyValveStatusEvent(
                        userId: userId,
                        subuserId: subuserId,
                        controllerId: controllerId,
                        fromDate: fromDate,
                        program: program,
                      ),
                    );
                  },
                );
              },
            ),
      
            /// 🔹 Date Picker
            IconButton(
              icon: const Icon(Icons.calendar_today),
              onPressed: () async {
                final result = await pickReportDate(
                  context: context,
                  allowRange: false,
                );
                if (result == null) return;
      
                final viewState =
                    context.read<TdyValveStatusCubit>().state;
      
                final program =
                (viewState.selectedProgramIndex + 1).toString();
      
                context.read<TdyValveStatusBloc>().add(
                  FetchTdyValveStatusEvent(
                    userId: userId,
                    subuserId: subuserId,
                    controllerId: controllerId,
                    fromDate: result.fromDate,
                    program: program,
                  ),
                );
              },
            ),
          ],
        ),
      
        /// 🔹 BODY → Bloc State (API)
        body: BlocBuilder<TdyValveStatusBloc, TdyValveStatusState>(
          builder: (context, state) {
            print("state:$state");
            if (state is TdyValveStatusLoading) {
              return const Center(child: CircularProgressIndicator());
            }
             if (state is TdyValveStatusError) {

              return Column(
                children: [
                  _programDropdown(context),
                  noData,
                ],
              );
            }
      
      
      
            if (state is TdyValveStatusLoaded) {
              return Column(
                children: [
                  _programDropdown(context),
                  const SizedBox(height: 12),
      
                  BlocBuilder<TdyValveStatusCubit, TdyValveViewState>(
            builder: (context, viewState) {
             return viewState.viewMode == TdyValveStatusViewMode.zoneStatus ? ZoneStatusCardTdyValveStatus(state.data) : TdyZoneStatusGraph(zones: state.data) ;
            },
            ),
                 ],
              );
            }
      
            return noData;
          },
        ),
      ),
    );
  }


  // 🔹 PROGRAM DROPDOWN
  Widget _programDropdown(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<int>(
        value: context.watch<TdyValveStatusCubit>().state.selectedProgramIndex,
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

          final cubit = context.read<TdyValveStatusCubit>();
          cubit.selectProgram(index);

          final program = (index + 1).toString();

          context.read<TdyValveStatusBloc>().add(
            FetchTdyValveStatusEvent(
              userId: userId,
              subuserId: subuserId,
              controllerId: controllerId,
              fromDate: fromDate,
              program: program,
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


