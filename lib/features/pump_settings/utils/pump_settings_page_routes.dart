import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/pages/notifications_page.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/pages/pump_settings_page.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/pages/view_pump_settings_page.dart';

import '../presentation/pages/pump_settings_menu_page.dart';

abstract class PumpSettingsPageRoutes {
  static const String pumpSettingMenuList = '/settingMenuList';
  static const String pumpSettingsPage = '/pumpSettingsPage';
  static const String notificationsPage = '/notificationsPage';
  static const String viewSettingsPage = '/viewSettingsPage';
}

final pumpSettingsRoutes = <GoRoute>[
  GoRoute(
    path: PumpSettingsPageRoutes.pumpSettingMenuList,
    name: 'settingMenuList',
    builder: (context, state) {
      final params = state.extra as Map<String, dynamic>;
      return PumpSettingsMenuPage(
        userId: params['userId'],
        subUserId: params['subUserId'],
        controllerId: params['controllerId'],
        deviceId: params['deviceId'],
      );
    },
  ),
  GoRoute(
    path: PumpSettingsPageRoutes.pumpSettingsPage,
    name: 'pumpSettingsPage',
    builder: (context, state) {
      final params = state.extra as Map<String, dynamic>;

      return PumpSettingsPage(
        menuId: params['menuId'],
        userId: params['userId'],
        subUserId: params['subUserId'],
        controllerId: params['controllerId'],
        menuName: params['menuName'],
        deviceId: params['deviceId'],
      );
    }
  ),
  GoRoute(
      path: PumpSettingsPageRoutes.notificationsPage,
      name: "notificationsPage",
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>;
        return NotificationsPage(
          userId: params['userId'],
          subUserId: params['subUserId'],
          controllerId: params['controllerId'],
        );
      }
  ),
  GoRoute(
      path: PumpSettingsPageRoutes.viewSettingsPage,
      name: "viewSettingsPage",
      builder: (context, state) {
        final params = state.extra as Map<String, dynamic>;
        return ViewPumpSettingsPage(
          deviceId: params['deviceId'],
        );
      }
  ),
];