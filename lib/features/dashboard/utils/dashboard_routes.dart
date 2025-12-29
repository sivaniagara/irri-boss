import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/auth.dart';

import '../../../core/di/injection.dart';
import '../../../core/utils/route_constants.dart';
import '../../controller_details/domain/usecase/controller_details_params.dart';
import '../../controller_details/presentation/bloc/controller_details_bloc.dart';
import '../../controller_details/presentation/bloc/controller_details_bloc_event.dart';
import '../../controller_details/presentation/pages/controller_details_page.dart';
import '../../controller_settings/utils/controller_settings_routes.dart';
import '../../irrigation_settings/utils/irrigation_settings_routes.dart';
import '../../program_settings/utils/program_settings_routes.dart';
import '../../setserialsettings/domain/usecase/setserial_details_params.dart';
import '../../setserialsettings/presentation/bloc/setserial_bloc.dart';
import '../../setserialsettings/presentation/bloc/setserial_bloc_event.dart';
import '../../setserialsettings/presentation/pages/setserial_page.dart';
import '../domain/entities/livemessage_entity.dart';
import '../presentation/bloc/dashboard_bloc.dart';
import '../presentation/bloc/dashboard_event.dart';
import '../presentation/pages/controller_live_page.dart';
import '../presentation/pages/dashboard_page.dart';
import '../presentation/pages/program_preview_page.dart';

class DashBoardRoutes {
  static const String dashboard = "/dashboard";
  static const String ctrlLivePage = "/ctrlLivePage";
  static const String programPreview = "/programPreview";
}

final dashboardRoutes = <GoRoute> [
  GoRoute(
    name: 'dashboard',
    path: DashBoardRoutes.dashboard,
    builder: (context, state) {
      final authData = _getAuthData();

      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => sl<DashboardBloc>()
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
    name: 'ctrlDetailsPage',
    path: RouteConstants.ctrlDetailsPage,
    builder: (context, state) {
      final params = state.extra as GetControllerDetailsParams;

      return BlocProvider(
        create: (_) => sl<ControllerDetailsBloc>()
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