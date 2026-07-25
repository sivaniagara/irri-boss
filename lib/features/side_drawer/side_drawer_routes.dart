import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/device_scan/bloc/device_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/device_scan/bloc/device_event.dart';
import 'package:niagara_smart_drip_irrigation/features/device_scan/pages/device_list_page.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/domain/usecases/get_sub_user_by_phone_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/domain/usecases/get_sub_user_details_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/domain/usecases/get_sub_users_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/domain/usecases/update_sub_user_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/presentation/bloc/sub_users_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/presentation/bloc/sub_users_event.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/presentation/pages/sub_user_details_page.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/presentation/pages/sub_users.dart';

import '../../core/di/injection.dart';
import '../../core/utils/route_constants.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_state.dart';
import '../controller_settings/utils/controller_settings_routes.dart';
import '../dashboard/presentation/pages/dashboard_page.dart';
import '../dashboard/utils/dashboard_routes.dart';
import '../dealer_dashboard/presentation/pages/dealer_dashboard_page.dart';
import '../dealer_dashboard/utils/dealer_routes.dart';
import '../irrigation_settings/utils/irrigation_settings_routes.dart';
import '../program_settings/utils/program_settings_routes.dart';
import '../standalone_settings/utils/standalone_routes.dart';
import 'groups/domain/usecases/add_group_usecase.dart';
import 'groups/domain/usecases/delete_group_usecase.dart';
import 'groups/domain/usecases/edit_group_usecase.dart';
import 'groups/domain/usecases/group_fetching_usecase.dart';
import 'groups/presentation/bloc/group_bloc.dart';
import 'groups/presentation/bloc/group_event.dart';
import 'groups/presentation/pages/chat.dart';
import 'groups/presentation/pages/groups.dart';
import 'groups/presentation/widgets/app_drawer.dart';
import 'groups/utils/group_routes.dart';
import 'sub_users/utils/sub_user_routes.dart';

final sideDrawerRoutes = <ShellRoute>[
  ShellRoute(
    builder: (context, state, child) {
      final location = state.matchedLocation;
      String title = 'Dashboard';
      if (location == GroupRoutes.groups) {
        title = 'Groups';
      } else if (location == SubUserRoutes.subUsers) {
        title = 'Sub Users';
      } else if (location == RouteConstants.QRScannerListPage) {
        title = 'Add Devices';
      } else if (location == SubUserRoutes.subUserDetails) {
        title = 'Sub User Details';
      }

      final authState = sl.get<AuthBloc>().state;
      final bool isAuthenticated = authState is Authenticated;
      final int userType = isAuthenticated ? authState.user.userDetails.userType : 1;
      final int userId = isAuthenticated ? authState.user.userDetails.id : 0;

      return BlocProvider.value(
        value: sl.get<AuthBloc>(),
        child: Scaffold(
          appBar: AppBar(
              backgroundColor: userType == 2 ? Theme.of(context).primaryColorDark : null,
              centerTitle: true,
              title: Text(title),
              leading: (location == DashBoardRoutes.dashboard || location == DealerRoutes.dealerDashboard)
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        if (isAuthenticated) {
                          final route = userType == 2 ? DealerRoutes.dealerDashboard : DashBoardRoutes.dashboard;
                          context.go('$route?userId=$userId&userType=$userType');
                        } else {
                          context.go('/');
                        }
                      },
                    ),
              foregroundColor: userType == 2 ? Colors.white : Colors.black,
              iconTheme: IconThemeData(color:  userType == 2 ? Colors.white : Colors.black)
          ),
          drawer: AppDrawer(userData: {"userId": '$userId', "userType": '$userType'},),
          body: child,
        ),
      );
    },
    routes: [
      GoRoute(
        name: "dealerDashboard",
        path: DealerRoutes.dealerDashboard,
        builder: (context, state) {
          final params = state.uri.queryParameters as Map<String, dynamic>;
          return DealerDashboardPage(userData: params);
        },
      ),
      GoRoute(
        name: 'groups',
        path: GroupRoutes.groups,
        builder: (context, state) {
          final authData = (sl.get<AuthBloc>().state as Authenticated).user.userDetails;
          final groupFetchingUseCase = sl<GroupFetchingUsecase>();
          final groupAddingUseCase = sl<GroupAddingUsecase>();
          final editGroupUsecase = sl<EditGroupUsecase>();
          final deleteGroupUsecase = sl<DeleteGroupUsecase>();
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
      GoRoute(
        name: 'subUsers',
        path: SubUserRoutes.subUsers,
        builder: (context, state) {
          final authData = (sl.get<AuthBloc>().state as Authenticated).user.userDetails;
          final getSubUserUsecase = sl<GetSubUsersUsecase>();
          final getSubUserDetailsUsecase = sl<GetSubUserDetailsUsecase>();
          final updateSubUserDetailsUsecase = sl<UpdateSubUserDetailsUseCase>();
          final getSubUserByPhoneUseCase = sl<GetSubUserByPhoneUsecase>();
          return BlocProvider.value(
            value: sl.get<AuthBloc>(),
            child: BlocProvider(
              create: (context) => SubUsersBloc(
                getSubUsersUsecase: getSubUserUsecase,
                getSubUserDetailsUsecase: getSubUserDetailsUsecase,
                updateSubUserDetailsUseCase: updateSubUserDetailsUsecase,
                getSubUserByPhoneUsecase: getSubUserByPhoneUseCase,
              )..add(GetSubUsersEvent(userId: authData.id)),
              child: SubUsers(userId: authData.id),
            ),
          );
        },
      ),
      GoRoute(
        name: 'subUserDetails',
        path: SubUserRoutes.subUserDetails,
        builder: (context, state) {
          final params = state.extra is Map ? state.extra as Map : null;
          final SubUsersBloc existingBloc = params?['existingBloc'] as SubUsersBloc;
          return BlocProvider.value(
            value: sl.get<AuthBloc>(),
            child: BlocProvider.value(
              value: existingBloc,
              child: SubUserDetailsScreen(
                subUserDetailsParams: GetSubUserDetailsParams(
                    userId: params?['userId'],
                    subUserCode: params?['subUserCode'],
                    isNewSubUser: params?['isNewSubUser']
                ),
              ),
            ),
          );
        },
      ),
      GoRoute(
        path: RouteConstants.QRScannerListPage,
        builder: (context, state) => BlocProvider(
          create: (context) => sl<QRDeviceBloc>()..add(LoadDevices()),
          child: const QRDeviceListPage(),
        ),
      ),
      GoRoute(
        name: 'QRScanner',
        path: RouteConstants.chat,
        builder: (context, state) => BlocProvider.value(
            value: sl.get<AuthBloc>(),
            child:  const Chat()
        ),
      ),
      GoRoute(
        path: DashBoardRoutes.dashboard,
        builder: (context, state) {
          final params = state.uri.queryParameters as Map<String, dynamic>;

          return DashboardPage(userData: params, child: null,);
        },
        routes: [
          ...controllerSettingGoRoutes,
          ...programSettingsGoRoutes,
          ...irrigationSettingGoRoutes,
          ...standaloneRoutes,

        ],
      ),
    ],
  )
];
