
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/presentation/pages/zone_cyclic_graph.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/presentation/pages/zone_cyclic_reports.dart';

import '../../../../../core/utils/common_date_picker.dart';
import '../../../../../core/widgets/glassy_wrapper.dart';
import '../../../../../core/widgets/no_data.dart';
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
    return GlassyWrapper(
      child: Scaffold(
        backgroundColor: const Color(0xFFE8F1F2),
        appBar: AppBar(
          title: const Text("Zone Cyclic Status"),
          actions: [
            /// 🔹 Toggle View
            BlocBuilder<ZoneCyclicBloc, ZoneCyclicState>(
              builder: (context, state) {
                return BlocBuilder<ZoneCyclicCubit, TdyValveViewState>(
                  builder: (context, viewState) {
                    return IconButton(
                      icon: Icon(
                        viewState.viewMode == ZoneCyclicViewMode.zoneStatus
                            ? Icons.bar_chart
                            : Icons.list_alt,
                      ),
                      onPressed: () {
                        context.read<ZoneCyclicCubit>().toggleView();
                        
                        // Use dates from state if available, otherwise fallback to initial
                        String currentFrom = fromDate;
                        String currentTo = toDate;
                        if (state is ZoneCyclicLoaded) {
                          currentFrom = state.fromDate;
                          currentTo = state.toDate;
                        }

                        context.read<ZoneCyclicBloc>().add(
                          FetchZoneCyclicEvent(
                            userId: userId,
                            subuserId: subuserId,
                            controllerId: controllerId,
                            fromDate: currentFrom,
                            toDate: currentTo,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            BlocBuilder<ZoneCyclicCubit, TdyValveViewState>(
              builder: (context, viewState) {
                return IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.black),
                  onPressed: () async {
                    final result = await pickReportDate(
                      context: context,
                      allowRange: true, // Always allow range for reports
                    );
                    if (result == null) return;
      
                    if (!context.mounted) return;
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
        body: BlocBuilder<ZoneCyclicBloc, ZoneCyclicState>(
          builder: (context, state) {
            if (state is ZoneCyclicLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is ZoneCyclicError) {
              return Column(
                children: [
                  _programDropdown(context, fromDate, toDate),
                  noData,
                ],
              );
            }
      
            if (state is ZoneCyclicLoaded) {
               return Column(
                children: [
                  _dateHeader(context, state.fromDate, state.toDate),
                  BlocBuilder<ZoneCyclicCubit, TdyValveViewState>(
                    builder: (context, viewState) {
                      return viewState.viewMode == ZoneCyclicViewMode.zoneStatus
                          ? const SizedBox()
                          : Padding(
                              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: _programDropdown(context, state.fromDate, state.toDate),
                            );
                    },
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(20),
                        ),
                        child: BlocBuilder<ZoneCyclicCubit, TdyValveViewState>(
                          builder: (context, viewState) {
                            if (viewState.viewMode == ZoneCyclicViewMode.zoneStatus) {
                              return ZoneCyclicPageReport(data: state.data);
                            } else {
                              final selectedProgram = (viewState.selectedProgramIndex + 1).toString();
                              final matchingPrograms = state.data.data
                                  .where((e) => e.program == selectedProgram)
                                  .toList();
                              final selectedProgramZones =
                              matchingPrograms.isNotEmpty ? matchingPrograms.first.zoneList : <ZoneCyclicDetailEntity>[];
                              
                              return ZoneCyclicGraph(
                                      zoneList: selectedProgramZones,
                                      totalFlow: state.data.totalFlow,
                                    );
                            }
                          },
                        ),
                      ),
                    ),
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

  Widget _dateHeader(BuildContext context, String fromDate, String toDate) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("From", style: TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(width: 8),
          Expanded(child: _dateBox(fromDate)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text("To", style: TextStyle(fontSize: 14, color: Colors.black87)),
          ),
          Expanded(child: _dateBox(toDate)),
        ],
      ),
    );
  }

  Widget _dateBox(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFD1E8FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFB3D7FF), width: 1),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          date, 
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          textAlign: TextAlign.center,
        )
      ),
    );
  }

  Widget _programDropdown(BuildContext context, String currentFrom, String currentTo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonFormField<int>(
        initialValue: context.watch<ZoneCyclicCubit>().state.selectedProgramIndex,
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

          context.read<ZoneCyclicBloc>().add(
            FetchZoneCyclicEvent(
              userId: userId,
              subuserId: subuserId,
              controllerId: controllerId,
              fromDate: currentFrom,
              toDate: currentTo,
            ),
          );
        },
      ),
    );
  }
}
