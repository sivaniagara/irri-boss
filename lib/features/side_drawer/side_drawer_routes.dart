import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
import '../../core/widgets/glassy_wrapper.dart';
import '../auth/domain/entities/user_entity.dart';
import '../auth/presentation/bloc/auth_bloc.dart';
import '../auth/presentation/bloc/auth_state.dart';
import '../dealer_dashboard/presentation/pages/dealer_dashboard_page.dart';
import '../dealer_dashboard/utils/dealer_routes.dart';
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
        value: sl.get<AuthBloc>(),
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
          value: sl.get<AuthBloc>(),
          child: const DealerDashboardPage(),
        ),
      ),
      GoRoute(
        name: 'groups',
        path: GroupRoutes.groups,
        builder: (context, state) {
          final authData = _getAuthData();
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
      _authRoute(
        name: 'subUsers',
        path: SubUserRoutes.subUsers,
        builder: (context, state) {
          final authData = _getAuthData();
          final getSubUserUsecase = sl<GetSubUsersUsecase>();
          final getSubUserDetailsUsecase = sl<GetSubUserDetailsUsecase>();
          final updateSubUserDetailsUsecase = sl<UpdateSubUserDetailsUseCase>();
          final getSubUserByPhoneUseCase = sl<GetSubUserByPhoneUsecase>();
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
          value: sl.get<AuthBloc>(),
          child: const DealerDashboardPage(),
        ),
      )
    ],
  ),
];

UserEntity _getAuthData() {
  final authState = sl.get<AuthBloc>().state;
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

Widget _buildWithAuthBloc(Widget child) => BlocProvider.value(value: sl.get<AuthBloc>(), child: child);

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