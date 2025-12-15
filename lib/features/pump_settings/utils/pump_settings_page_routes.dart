import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/cubit/pump_settings_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/pages/pump_settings_page.dart';

import '../../../core/di/injection.dart' as di;
import '../presentation/bloc/pump_settings_event.dart';
import '../presentation/bloc/pump_settings_menu_bloc.dart';
import '../presentation/pages/pump_settings_menu_page.dart';

abstract class PumpSettingsPageRoutes {
  static const String pumpSettingMenuList = '/settingMenuList';
  static const String pumpSettingsPage = '/pumpSettingsPage';
}

final pumpSettingsRoutes = <GoRoute>[
  GoRoute(
    path: PumpSettingsPageRoutes.pumpSettingMenuList,
    name: 'settingMenuList',
    builder: (context, state) {
      final params = state.extra as Map<String, dynamic>;

      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => di.sl<PumpSettingsMenuBloc>()
              ..add(GetPumpSettingsMenuEvent(
                userId: params['userId'],
                subUserId: params['subUserId'],
                controllerId: params['controllerId'],
              )),
          ),

          // ADD THIS
          BlocProvider(
            create: (_) => di.sl<PumpSettingsCubit>(),
          ),
        ],
        child: PumpSettingsMenuPage(
          userId: params['userId'],
          subUserId: params['subUserId'],
          controllerId: params['controllerId'],
        ),
      );

    },
  ),
  GoRoute(
    path: PumpSettingsPageRoutes.pumpSettingsPage,
    name: 'pumpSettingsPage',
    builder: (context, state) {
      final params = state.extra as Map<String, dynamic>;

      final PumpSettingsCubit cubit = params["cubit"];

      cubit.loadSettings(
        userId: params['userId'],
        subUserId: params['subUserId'],
        controllerId: params['controllerId'],
        menuId: params['menuId'],
      );

      return BlocProvider.value(
        value: cubit,
        child: PumpSettingsPage(
          menuId: params['menuId'],
          userId: params['userId'],
          subUserId: params['subUserId'],
          controllerId: params['controllerId'],
          menuName: params['menuName'],
        ),
      );
    }
  ),
];