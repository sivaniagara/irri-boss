import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/pages/irrigation_settings_page.dart';

import '../../../core/di/injection.dart' as di;
import '../../progam_zone_set/presentation/cubit/program_tab_cubit.dart';
import '../../progam_zone_set/utils/program_tab_routes.dart';
import '../../water_fertilizer_settings/presentation/bloc/water_fertilizer_setting_bloc.dart';

class IrrigationSettingsRoutes {
  static const String irrigationSettings = "/irrigationSettings";
}

final irrigationSettingGoRoutes = [
  GoRoute(
      path: IrrigationSettingsRoutes.irrigationSettings,
      builder: (context, state) {
        return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context)=> di.sl<WaterFertilizerSettingBloc>(),
              )
            ],
            child: IrrigationSettingsPage()
        );
      },
      routes: [
        ...programTabRoutesGoRoutes
      ]
  ),
];