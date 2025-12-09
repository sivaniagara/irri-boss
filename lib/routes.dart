import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/utils/pump_settings_page_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/utils/sub_user_routes.dart';
import 'features/dashboard/utils/dashboard_routes.dart';
import 'features/side_drawer/groups/utils/group_routes.dart';
import 'features/auth/utils/auth_routes.dart';

import 'core/di/injection.dart' as di;
import 'core/utils/route_constants.dart';
import 'core/widgets/glassy_wrapper.dart';
import 'features/dealer_dashboard/presentation/pages/dealer_dashboard_page.dart';
import 'features/side_drawer/groups/presentation/pages/chat.dart';
import 'features/side_drawer/groups/presentation/widgets/app_drawer.dart';
import 'features/auth/auth.dart';
import 'features/dashboard/dashboard.dart';
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

class AppRouter {
  late final GoRouter router;
  final AuthBloc authBloc;

  AppRouter({required this.authBloc}) {
    router = GoRouter(
      initialLocation: AuthRoutes.login,
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
            final bloc = BlocProvider(
              create: (context) => di.sl<DashboardBloc>()
                ..add(FetchDashboardGroupsEvent(authData.id))
                ..add(ResetDashboardSelectionEvent()),
              child: DashboardPage(userId: authData.id, userType: authData.userType),
            );
            return bloc;
          },
        ),
        GoRoute(
          name: 'ctrlLivePage',
          path: DashBoardRoutes.ctrlLivePage,
          builder: (context, state) {
            print('Building ctrlLivePage, AuthBloc state: ${authBloc.state}');
            final selectedController = state.extra as LiveMessageEntity?;
            return BlocProvider.value(
              value: authBloc,
              child: CtrlLivePage(selectedController: selectedController),
            );
          },
        ),
        ...pumpSettingsRoutes,
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
          ],
        ),
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
