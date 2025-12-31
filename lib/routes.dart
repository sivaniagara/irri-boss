import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/pages/node_status_page.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/utils/pump_settings_page_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/utils/sub_user_routes.dart';
import 'core/di/injection.dart';
import 'features/controller_details/domain/usecase/controller_details_params.dart';
import 'features/controller_details/presentation/bloc/controller_details_bloc.dart';
import 'features/controller_details/presentation/bloc/controller_details_bloc_event.dart';
import 'features/controller_details/presentation/pages/controller_details_page.dart';
import 'features/controller_settings/utils/controller_settings_routes.dart';
import 'features/dashboard/domain/entities/livemessage_entity.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_event.dart';
import 'features/dashboard/presentation/pages/controller_live_page.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/dashboard/presentation/pages/program_preview_page.dart';
import 'features/dashboard/utils/dashboard_routes.dart';
import 'features/irrigation_settings/utils/irrigation_settings_routes.dart';
import 'features/fault_msg/utils/faultmsg_routes.dart';
import 'features/report_downloader/utils/report_downloaderRoute.dart';
import 'features/reports/Motor_cyclic_reports/utils/motor_cyclic_routes.dart';
import 'features/reports/Voltage_reports/utils/voltage_routes.dart';
import 'features/reports/flow_graph_reports/utils/flow_graph_routes.dart';
import 'features/reports/power_reports/utils/Power_routes.dart';
import 'features/reports/reportMenu/utils/report_routes.dart';
import 'features/reports/standalone_reports/utils/standalone_routes.dart';
import 'features/reports/tdyvalvestatus_reports/utils/tdy_valve_status_routes.dart';
import 'features/reports/zone_duration_reports/utils/zone_duration_routes.dart';
import 'features/reports/zonecyclic_reports/utils/zone_cyclic_routes.dart';
import 'features/sendrev_msg/utils/senrev_routes.dart';
import 'features/program_settings/utils/program_settings_routes.dart';
import 'features/setserialsettings/domain/usecase/setserial_details_params.dart';
import 'features/setserialsettings/presentation/bloc/setserial_bloc.dart';
import 'features/setserialsettings/presentation/bloc/setserial_bloc_event.dart';
import 'features/setserialsettings/presentation/pages/setserial_page.dart';
import 'features/side_drawer/groups/utils/group_routes.dart';
import 'features/auth/utils/auth_routes.dart';

import 'core/di/injection.dart' as di;
import 'core/utils/route_constants.dart';
import 'core/widgets/glassy_wrapper.dart';
import 'features/dealer_dashboard/presentation/pages/dealer_dashboard_page.dart';
import 'features/side_drawer/groups/presentation/pages/chat.dart';
import 'features/side_drawer/groups/presentation/widgets/app_drawer.dart';
import 'features/auth/auth.dart';
import 'features/side_drawer/sub_users/sub_users_barrel.dart';
import 'features/side_drawer/groups/groups_barrel.dart';

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
          if (authState.user.userDetails.userType == 2) {
            return DealerRoutes.dealerDashboard;
          } else if (authState.user.userDetails.userType == 1) {
            return DashBoardRoutes.dashboard;
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
        GoRoute(
          name: 'dashboard',
          path: DashBoardRoutes.dashboard,
          builder: (context, state) {
            final authData = _getAuthData();

            return MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (_) => di.sl<DashboardBloc>()
                    ..add(FetchDashboardGroupsEvent(authData.id))
                    ..add(ResetDashboardSelectionEvent()),
                ),

              ],
              child: DashboardPage(
                userId: authData.id,
                userType: authData.userType,
              ),
            );
          },
          routes: [
            ...controllerSettingGoRoutes,
            ...programSettingsGoRoutes,
            ...irrigationSettingGoRoutes,
          ],
        ),
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
              child: SerialSetCalibrationPage(userId: params.userId,controllerId: params.controllerId, type: params.type,),
            );
          },
        ),
        ShellRoute(
          builder: (context, state, child) {
            final location = state.matchedLocation;
            String title = 'Dealer Dashboard';
            if (location == GroupRoutes.groups) {
              title = 'Groups';
            } else if (location == SubUserRoutes.subUsers) {
              title = 'Sub Users';
            } else if (location == RouteConstants.chat) {
              title = 'Chat';
            } else if (location == SubUserRoutes.subUserDetails) {
              title = 'Sub User Details';
            }

            return BlocProvider.value(
              value: authBloc,
              child: Scaffold(
                appBar: AppBar(centerTitle: true, title: Text(title)),
                drawer: const AppDrawer(),
                body: GlassyWrapper(
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (notification) {
                      notification.disallowIndicator();
                      return true;
                    },
                    child: child,
                  ),
                ),
              ),
            );
          },
          routes: [
            GoRoute(
              name: 'dealerDashboard',
              path: DealerRoutes.dealerDashboard,
              builder: (context, state) => BlocProvider.value(
                value: authBloc,
                child: const DealerDashboardPage(),
              ),
            ),
            GoRoute(
              name: 'groups',
              path: GroupRoutes.groups,
              builder: (context, state) {
                final authData = _getAuthData();
                final groupFetchingUseCase = di.sl<GroupFetchingUsecase>();
                final groupAddingUseCase = di.sl<GroupAddingUsecase>();
                final editGroupUsecase = di.sl<EditGroupUsecase>();
                final deleteGroupUsecase = di.sl<DeleteGroupUsecase>();
                return BlocProvider(
                  create: (context) => GroupBloc(
                    groupFetchingUsecase: groupFetchingUseCase,
                    groupAddingUsecase: groupAddingUseCase,
                    editGroupUsecase: editGroupUsecase,
                    deleteGroupUsecase: deleteGroupUsecase,
                  )..add(FetchGroupsEvent(authData.id)),
                  child: GroupsPage(userId: authData.id),
                );
              },
            ),
            _authRoute(
              name: 'subUsers',
              path: SubUserRoutes.subUsers,
              builder: (context, state) {
                final authData = _getAuthData();
                final getSubUserUsecase = di.sl<GetSubUsersUsecase>();
                final getSubUserDetailsUsecase = di.sl<GetSubUserDetailsUsecase>();
                final updateSubUserDetailsUsecase = di.sl<UpdateSubUserDetailsUseCase>();
                final getSubUserByPhoneUseCase = di.sl<GetSubUserByPhoneUsecase>();
                return BlocProvider(
                  create: (context) => SubUsersBloc(
                    getSubUsersUsecase: getSubUserUsecase,
                    getSubUserDetailsUsecase: getSubUserDetailsUsecase,
                    updateSubUserDetailsUseCase: updateSubUserDetailsUsecase,
                    getSubUserByPhoneUsecase: getSubUserByPhoneUseCase,
                  )..add(GetSubUsersEvent(userId: authData.id)),
                  child: SubUsers(userId: authData.id),
                );
              },
            ),
            _authRoute(
              name: 'subUserDetails',
              path: SubUserRoutes.subUserDetails,
              builder: (context, state) {
                final params = state.extra is Map ? state.extra as Map : null;
                final SubUsersBloc existingBloc = params?['existingBloc'] as SubUsersBloc;
                return BlocProvider.value(
                  value: existingBloc,
                  child: SubUserDetailsScreen(
                    subUserDetailsParams: GetSubUserDetailsParams(
                        userId: params?['userId'],
                        subUserCode: params?['subUserCode'],
                        isNewSubUser: params?['isNewSubUser']
                    ),
                  ),
                );
              },
            ),
            _authRoute(
              name: 'chat',
              path: RouteConstants.chat,
              builder: (context, state) => const Chat(),
            ),
            GoRoute(
              path: DealerRoutes.dealerDashboard,
              builder: (context, state) => BlocProvider.value(
                value: authBloc,
                child: const DealerDashboardPage(),
              ),
            )
          ],
        ),
        ...pumpSettingsRoutes,
        ...reportPageRoutes,
        ...sendRevPageRoutes,
        ...FaultMsgPagesRoutes,
        ...voltGraphRoutes,
        ...PowerGraphRoutes,
        ...ReportDownloadRoutes,
        ...MotorCyclicRoutes,
        ...ZoneDurationRoutes,
        ...StandaloneRoutes,
        ...TdyValveStatusRoutes,
        ...ZoneCyclicRoutes,
        ...FlowGraphRoutes,
      ],
    );
  }

  UserEntity _getAuthData() {
    final authState = authBloc.state;
    if (authState is Authenticated) {
      return authState.user.userDetails;
    }
    return UserEntity(
      id: 0,
      name: '',
      mobile: '',
      userType: 0,
      deviceToken: '',
      mobCctv: '',
      webCctv: '',
      altPhoneNum: [],
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