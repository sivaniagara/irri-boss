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
import '../../core/utils/app_images.dart';
import '../../core/utils/route_constants.dart';
import '../../core/widgets/glassy_wrapper.dart';
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
        child: GlassyWrapper(
          child: Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: (sl.get<AuthBloc>().state as Authenticated).user.userDetails.userType == 2 ? Container(
                  width: 140,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Image.asset(AppImages.logoSmall),
                ) : Text(title)
            ),
            drawer: const AppDrawer(),
            body: child,
          ),
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
        name: 'chat',
        path: RouteConstants.chat,
        builder: (context, state) => BlocProvider.value(
            value: sl.get<AuthBloc>(),
            child:  const Chat()
        ),
      ),
    ],
  )
];