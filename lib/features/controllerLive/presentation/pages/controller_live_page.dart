// lib/features/dashboard/presentation/pages/dashboard_page.dart
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glass_effect.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/fertstatus_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/previousday_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/prs_gauge_section.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/widgets/well_level_section.dart';
import '../../../../core/utils/route_constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';
import '../../../dashboard/presentation/bloc/dashboard_state.dart';
import '../../../my_device/presentation/widgets/ctrl_display.dart';
import '../../../my_device/presentation/widgets/latestmsg_section.dart';
import '../../../my_device/presentation/widgets/pressure_section.dart';
import '../../../my_device/presentation/widgets/ryb_section.dart';
import '../../../my_device/presentation/widgets/timer_section.dart';
import 'package:get_it/get_it.dart' as di;
import '../widgets/livepage_display_values.dart';

class CtrlLivePage extends StatelessWidget {
  const CtrlLivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = di.GetIt.instance.get<DashboardBloc>();
        final authState = context.read<AuthBloc>().state;
        if (authState is Authenticated) {
          if (bloc.state is! DashboardLoading && bloc.state is! DashboardGroupsLoaded) {
            bloc.add(FetchDashboardGroupsEvent(authState.user.userDetails.id));
          }
        }
        return bloc;
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            final dashboardBloc = context.read<DashboardBloc>();
            if (dashboardBloc.state is! DashboardLoading && dashboardBloc.state is! DashboardGroupsLoaded) {
              dashboardBloc.add(FetchDashboardGroupsEvent(state.user.userDetails.id));
            }
          } else if (state is LoggedOut) {
            context.go(RouteConstants.login);
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              return BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, dashboardState) {
                  if (dashboardState is DashboardGroupsLoaded) {
                    // Assume bloc handles initial selection; if not, dispatch here once
                    final bloc = context.read<DashboardBloc>();
                    if (dashboardState.selectedGroupId == null && dashboardState.groups.isNotEmpty) {
                      // Dispatch once to select first group
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!bloc.isClosed) {
                          bloc.add(SelectGroupEvent(dashboardState.groups[0].userGroupId));
                        }
                      });
                    }

                    final controllers = dashboardState.groupControllers[dashboardState.selectedGroupId] ?? [];
                    int effectiveIndex = dashboardState.selectedControllerIndex ?? 0; // Default to 0

                    // Clamp index to valid range (0 to length-1)
                    if (effectiveIndex >= controllers.length || effectiveIndex < 0) {
                      effectiveIndex = controllers.isNotEmpty ? 0 : -1; // -1 signals no selection
                    }

                    final selectedController = effectiveIndex >= 0 ? controllers[effectiveIndex] : null;
                      return Scaffold(
                       appBar: AppBar(
                        title:  Text("Controller Live Page"),
                       ),
                      body:  SingleChildScrollView(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primaryContainer,
                                Colors.black87,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GlassCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                   const SizedBox(height: 8),
                                  Center(child: Text("Last sync: ${selectedController?.livesyncTime ?? ''}", textAlign: TextAlign.center,style: const TextStyle(fontSize: 12,color: Colors.white,))),
                                  const SizedBox(height: 8),
                                  GlassCard(
                                    child: CtrlDisplay(
                                      signal: 50,
                                      battery: 50,
                                      status: selectedController?.status ?? '',
                                      vrb: 456,
                                      amp: 200,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset(
                                        selectedController?.liveMessage.motorOnOff == "0"
                                            ? 'assets/images/common/ui_motor.gif' // motor ON
                                            : selectedController?.liveMessage.motorOnOff == "1"
                                            ? 'assets/images/common/live_motor_off.png' // motor OFF
                                            : 'assets/images/common/ui_motor_yellow.png', // no status
                                        width: 60,
                                        height: 60,
                                      ),
                                      LatestMsgSection(
                                        msg: ([1, 5].contains(selectedController?.modelId ?? 0))
                                            ? selectedController?.msgDesc ?? ''
                                            : "${selectedController?.msgDesc ?? ''} \n ${selectedController?.ctrlLatestMsg ?? ''}",
                                      ),
                                      Image.asset(
                                        selectedController?.liveMessage.valveOnOff == "0"
                                            ? 'assets/images/common/valve_open.gif' // valve open
                                            : selectedController?.liveMessage.valveOnOff == "1"
                                            ? 'assets/images/common/valve_stop.png' // valve stop
                                            : 'assets/images/common/valve_no_communication.png', // no communication
                                        width: 60,
                                        height: 60,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  RYBSection(
                                    r: selectedController?.liveMessage.rVoltage ?? "",
                                    y: selectedController?.liveMessage.yVoltage ?? "",
                                    b: selectedController?.liveMessage.bVoltage ?? "",
                                    c1: selectedController?.liveMessage.rCurrent ?? "",
                                    c2: selectedController?.liveMessage.yCurrent ?? "",
                                    c3: selectedController?.liveMessage.bCurrent ?? "",
                                  ),
                                  const SizedBox(height: 8),
                                  if ([1, 5].contains(selectedController?.modelId ?? 0))
                                    Column(
                                      children: [
                                        PressureSection(
                                          prsIn: selectedController?.liveMessage.prsIn ?? '',
                                          prsOut: selectedController?.liveMessage.prsOut ?? '',
                                          activeZone: selectedController?.zoneNo ?? '',
                                          fertlizer: '',
                                        ),
                                        const SizedBox(height: 8),
                                        TimerSection(
                                          setTime: selectedController?.setFlow ?? '',
                                          remainingTime: selectedController?.remFlow ?? '',
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8),
                                  TimerSection(
                                    setTime: selectedController?.setFlow ?? '00:00:00',
                                    remainingTime: selectedController?.remFlow ?? '00:00:00',
                                  ),
                                  const SizedBox(height: 8),
                                   GlassCard(
                                    padding: const EdgeInsets.all(0),
                                    margin: const EdgeInsets.all(0),
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Your LiveDisplayObject is used here
                                          LiveDisplayObject(
                                            disMsg1: "Phase",
                                            disValues1: "2-Phase",
                                            disMsg2: "Bat.V",
                                            disValues2: "4.4V",
                                          ),
                                          const SizedBox(height: 10),
                                          LiveDisplayObject(
                                            disMsg1: "Program",
                                            disValues1: "Program 2",
                                            disMsg2: "Mode",
                                            disValues2: "Timer",
                                          ),
                                          const SizedBox(height: 10),
                                          LiveDisplayObject(
                                            disMsg1: "Zone",
                                            disValues1: "001",
                                            disMsg2: "Valve",
                                            disValues2: "V,1,2,3",
                                          ),
                                          const SizedBox(height: 10),
                                          PressureGaugeSection(prsIn: 2.5, prsOut: 3.5, fertFlow: 200),
                                          const SizedBox(height: 10),
                                          WellLevelSection(level: 34, flow: 343)

                                         ],
                                      ),
                                    ),
                                  ),
                                  FertStatusSection(F1: "1", F2: "2", F3: "0", F4: "1", F5: "1", F6: "0"),
                                  const SizedBox(height: 10),
                                  GlassCard(
                                    child: Center(
                                      child: LiveDisplayObject(
                                        disMsg1: "Ec",
                                        disValues1: "21.3",
                                        disMsg2: "PH",
                                        disValues2: "7.0",
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  GlassCard(
                                    child: Center(
                                      child: Column(
                                        children: [
                                          LiveDisplayObject(
                                            disMsg1: "F1",
                                            disValues1: "00:00",
                                            disMsg2: "F2",
                                            disValues2: "00:00",
                                          ),
                                          LiveDisplayObject(
                                            disMsg1: "F3",
                                            disValues1: "00:00",
                                            disMsg2: "F4",
                                            disValues2: "00:00",
                                          ),
                                          LiveDisplayObject(
                                            disMsg1: "F5",
                                            disValues1: "00:00",
                                            disMsg2: "F6",
                                            disValues2: "00:00",
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  PreviousDaySection(runTimeToday: "00:23:00", runTimePrevious: "00:23:00", flowToday: "1234", flowPrevious: "4234", cFlowToday: "23", cFlowPrevious: "34"),
                                  const SizedBox(height: 10),
                                  GlassCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white30,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "Version:",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: CupertinoColors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "V3.22.23.2",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (dashboardState is DashboardLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (dashboardState is DashboardError) {
                    return Center(child: Text('Error: ${dashboardState.message}'));
                  }
                  return const SizedBox.shrink(); // Fallback
                },
              );
            } else if (authState is AuthLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (authState is AuthError) {
              return Center(
                child: Column(
                  children: [
                    Text('Error: ${authState.message}'),
                    ElevatedButton(
                      onPressed: () => context.read<AuthBloc>().add(CheckCachedUserEvent()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: Text('Please log in'));
            }
          },
        ),
      ),
    );
  }


}

