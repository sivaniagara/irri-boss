import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/pages/irrigation_settings_page.dart';

import '../../progam_zone_set/utils/program_tab_routes.dart';

class IrrigationSettingsRoutes {
  static const String irrigationSettings = "/irrigationSettings";
}

final irrigationSettingGoRoutes = [
  GoRoute(
      path: IrrigationSettingsRoutes.irrigationSettings,
      builder: (context, state) {
        return IrrigationSettingsPage();
      },
      routes: [
        ...programTabRoutesGoRoutes
      ]
  ),
];