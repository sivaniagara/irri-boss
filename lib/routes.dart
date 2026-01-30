import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/alarm_settings/utils/alarm_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/pages/dashboard_2_0.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/pages/node_status_page.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/utils/pump_settings_page_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/green_house_reports/utils/green_house_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/moisture_reports/utils/moisture_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/service_request/utils/service_request_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/settings/presentation/pages/settings_page.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/utils/sub_user_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/bloc/standalone_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/bloc/standalone_event.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/pages/configuration_page.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/pages/standalone_page.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/utils/standalone_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/valve_flow_settings/utils/valve_flow_routes.dart';
import 'core/di/injection.dart';
import 'features/common_id_settings/utils/common_id_settings_routes.dart';
import 'features/controller_details/domain/usecase/controller_details_params.dart';
import 'features/controller_details/presentation/bloc/controller_details_bloc.dart';
import 'features/controller_details/presentation/bloc/controller_details_bloc_event.dart';
import 'features/controller_details/presentation/pages/controller_details_page.dart';
import 'features/controller_settings/utils/controller_settings_routes.dart';
import 'features/dashboard/domain/entities/livemessage_entity.dart';
import 'features/dashboard/presentation/pages/controller_live_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/dashboard/presentation/pages/program_preview_page.dart';
import 'features/dashboard/utils/dashboard_routes.dart';
import 'features/dealer_dashboard/utils/dealer_routes.dart';
import 'features/edit_program/utils/edit_program_routes.dart';
import 'features/irrigation_settings/utils/irrigation_settings_routes.dart';
import 'features/fault_msg/utils/faultmsg_routes.dart';
import 'features/mapping_and_unmapping_nodes/utils/mapping_and_unmapping_nodes_routes.dart';
import 'features/report_downloader/utils/report_downloaderRoute.dart';
import 'features/reports/Motor_cyclic_reports/utils/motor_cyclic_routes.dart';
import 'features/reports/fertilizer_reports/utils/fertilizer_routes.dart';
import 'features/reports/flow_graph_reports/utils/flow_graph_routes.dart';
import 'features/reports/power_reports/utils/Power_routes.dart';
import 'features/reports/reportMenu/utils/report_routes.dart';
import 'features/reports/standalone_reports/utils/standalone_report_routes.dart';
import 'features/reports/tdy_valve_status_reports/utils/tdy_valve_status_routes.dart';
import 'features/reports/zone_duration_reports/utils/zone_duration_routes.dart';
import 'features/reports/zonecyclic_reports/utils/zone_cyclic_routes.dart';
import 'features/sendrev_msg/utils/senrev_routes.dart';
import 'features/program_settings/utils/program_settings_routes.dart';

import 'features/set_serial_settings/domain/usecase/set_serial_details_params.dart';
import 'features/set_serial_settings/presentation/bloc/set_serial_bloc.dart';
import 'features/set_serial_settings/presentation/bloc/set_serial_bloc_event.dart';
import 'features/set_serial_settings/presentation/pages/set_serial_page.dart';
import 'features/auth/utils/auth_routes.dart';

import 'core/di/injection.dart' as di;
import 'core/utils/route_constants.dart';
import 'features/auth/auth.dart';
import 'features/side_drawer/side_drawer_routes.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  StreamSubscription? _subscription;

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

Widget pageSlider(context, animation, secondaryAnimation, child){
  const begin = Offset(2.0, 0.0);
  const end = Offset.zero;
  const curve = Curves.easeInOut;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

  return SlideTransition(
    position: animation.drive(tween),
    child: child,
  );
}

class AppRouter {
  late final GoRouter router;
  final AuthBloc authBloc;

  AppRouter({required this.authBloc}) {
    router = GoRouter(
      initialLocation: AuthRoutes.login,
      // initialLocation: ControllerSettingsRoutes.program,
      debugLogDiagnostics: true,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isLoggedIn = authState is Authenticated;
        final isOtpSent = authState is OtpSent;

        final location = state.matchedLocation;

        final isPublicRoute = location == AuthRoutes.login ||
            location == AuthRoutes.verifyOtp ||
            location == AuthRoutes.signUp;

        if (isOtpSent && location != AuthRoutes.verifyOtp) {
          return AuthRoutes.verifyOtp;
        }

        if (isLoggedIn && (location == AuthRoutes.login || location == AuthRoutes.verifyOtp)) {
          final userId = authState.user.userDetails.id;
          final userType = authState.user.userDetails.userType;
          if (authState.user.userDetails.userType == 2) {
            return '${DealerRoutes.dealerDashboard}?userId=$userId&userType=$userType';
          } else if (authState.user.userDetails.userType == 1) {
            return '${DashBoardRoutes.dashboard}?userId=$userId&userType=$userType';
          }
        }

        if (!isLoggedIn && !isOtpSent && !isPublicRoute) {
          return AuthRoutes.login;
        }

        return null;
      },
      routes: [
        _authRoute(
          name: 'login',
          path: AuthRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        _authRoute(
          name: 'signUp',
          path: AuthRoutes.signUp,
          builder: (context, state) => UserProfileForm(isEdit: false),
        ),
        _authRoute(
          name: 'editProfile',
          path: AuthRoutes.editProfile,
          builder: (context, state) {
            final authState = authBloc.state;
            final initialData = authState is Authenticated ? authState.user.userDetails : null;
            return UserProfileForm(
              key: const ValueKey('editProfile'),
              isEdit: true,
              initialData: initialData,
            );
          },
        ),
        _authRoute(
          name: 'verifyOtp',
          path: AuthRoutes.verifyOtp,
          builder: (context, state) {
            final authState = authBloc.state;
            final params = state.extra is Map ? state.extra as Map : null;
            final verificationId = params?['verificationId'] ?? (authState is OtpSent ? authState.verificationId : '');
            final phone = params?['phone'] ?? (authState is OtpSent ? authState.phone : '');
            final countryCode = params?['countryCode'] ?? (authState is OtpSent ? authState.countryCode : '');

            if (verificationId.isEmpty || phone.isEmpty) {
              return const LoginPage();
            }

            return OtpVerificationPage(
              verificationId: verificationId,
              phone: phone,
              countryCode: countryCode,
            );
          },
        ),
        ShellRoute(
            builder: (context, state, child){
              return DashboardPage(userData: {}, child: child,);
            },
            routes: [
              GoRoute(
                  path: DashBoardRoutes.dashboard,
                  builder: (context, state) {
                    return Dashboard20();
                  },
              ),
              GoRoute(
                  path: DashBoardRoutes.report,
                  builder: (context, state) {
                    return Center(
                      child: Text('Report'),
                    );
                  },
                  routes: [

                  ]
              ),
              GoRoute(
                  path: DashBoardRoutes.standalone,
                  builder: (context, state) {
                    final params = state.extra as Map<String, dynamic>;
                    final userId = params["userId"]?.toString() ?? '';
                    final controllerId = params["controllerId"]?.toString() ?? '';
                    final deviceId = params["deviceId"]?.toString() ?? '';
                    final subUserId = params["subUserId"]?.toString() ?? '0';

                    return BlocProvider.value(
                      value: di.sl<StandaloneBloc>(),
                      child: Builder(
                        builder: (context) {
                          final bloc = context.read<StandaloneBloc>();
                          if (bloc.state is StandaloneInitial) {
                            bloc.add(FetchStandaloneDataEvent(
                                userId: userId,
                                controllerId: controllerId,
                                deviceId: deviceId,
                                subUserId: subUserId
                            ));
                          }
                          return StandalonePage(data: params);
                        },
                      ),
                    );
                  },
              ),
              GoRoute(
                path: DashBoardRoutes.configuration,
                builder: (context, state) {
                  final params = state.extra as Map<String, dynamic>;
                  return BlocProvider.value(
                    value: di.sl<StandaloneBloc>(),
                    child: ConfigurationPage(data: params),
                  );
                },
              ),
              GoRoute(
                  path: DashBoardRoutes.settings,
                  builder: (context, state) {
                    return SettingsPage();
                  },
                  routes: [

                  ]
              ),
              GoRoute(
                  path: DashBoardRoutes.sentAndReceive,
                  builder: (context, state) {
                    return Center(
                      child: Text('sentAndReceive'),
                    );
                  },
                  routes: [

                  ]
              ),
            ]
        ),
        ...editProgramGoRoutes,
        ...irrigationSettingGoRoutes,
        ...mappingAndUnmappingNodesGoRoutes,
        ...commonIdSettingsGoRoutes,
        GoRoute(
            name: 'ctrlLivePage',
            path: DashBoardRoutes.ctrlLivePage,
            builder: (context, state) {
              print('Building ctrlLivePage, AuthBloc state: ${sl.get<AuthBloc>().state}');
              final selectedController = state.extra as LiveMessageEntity?;
              return BlocProvider.value(
                value: sl.get<AuthBloc>(),
                child: CtrlLivePage(selectedController: selectedController),
              );
            },
            routes: [
            ]
        ),
        GoRoute(
          name: 'programPreview',
          path: DashBoardRoutes.programPreview,
          builder: (context, state) {
            final String deviceId = state.extra as String;
            return ProgramPreviewPage(deviceId: deviceId,);
          },
        ),
        GoRoute(
          name: 'nodeStatus',
          path: DashBoardRoutes.nodeStatus,
          builder: (context, state) {
            final data = state.extra as Map<String, dynamic>;
            return NodeStatusPage(
              userId: data['userId'],
              controllerId: data['controllerId'],
              subuserId: data['subuserId'],
              deviceId: data['deviceId'],
            );
          },
        ),
        GoRoute(
          name: 'ctrlDetailsPage',
          path: RouteConstants.ctrlDetailsPage,
          builder: (context, state) {
            final params = state.extra as GetControllerDetailsParams;

            return BlocProvider(
              create: (_) => di.sl<ControllerDetailsBloc>()
                ..add(GetControllerDetailsEvent(
                  userId: params.userId,
                  controllerId: params.controllerId,
                  deviceId: params.deviceId,
                )),
              child: ControllerDetailsPage(params: params),
            );
          },
        ),
        GoRoute(
          name: 'setSerialPage',
          path: RouteConstants.setSerialPage,
          builder: (context, state) {
            final params = state.extra as SetSerialParams;
            return BlocProvider(create: (_) => sl<SetSerialBloc>()
              ..add(LoadSerialEvent(userId: params.userId,controllerId: params.controllerId,)),
              child: SerialSetCalibrationPage(userId: params.userId,controllerId: params.controllerId, type: params.type,deviceId: params.deviceId,),
            );
          },
        ),
        ...DealerRoutes.dealerRoutes,
        ...serviceRequestRoutes,
        ...sideDrawerRoutes,
        ...pumpSettingsRoutes,
        ...reportPageRoutes,
        ...sendRevPageRoutes,
        ...FaultMsgPagesRoutes,
        ...PowerGraphRoutes,
        ...ReportDownloadRoutes,
        ...MotorCyclicRoutes,
        ...ZoneDurationRoutes,
        ...standaloneReportRoutes,
        ...TdyValveStatusRoutes,
        ...ZoneCyclicRoutes,
        ...FlowGraphRoutes,
        ...moistureRoutes,
        ...fertilizerRoutes,
        ...greenHouseReportRoutes,
        ...ValveFlowRoutes.routes,
        ...AlarmRoutes.routes,
      ],
    );
  }


  Widget _buildWithAuthBloc(Widget child) => BlocProvider.value(value: authBloc, child: child);

  GoRoute _authRoute({
    required String name,
    required String path,
    required Widget Function(BuildContext, GoRouterState) builder,
  }) {
    return GoRoute(
      name: name,
      path: path,
      builder: (context, state) => _buildWithAuthBloc(builder(context, state)),
    );
  }
}