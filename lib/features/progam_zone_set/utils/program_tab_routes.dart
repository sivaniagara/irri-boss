import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/utils/irrigation_settings_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/presentation/pages/mapping_and_unmapping_page.dart';
import '../../../core/di/injection.dart' as di;
import '../../mapping_and_unmapping_nodes/presentation/bloc/mapping_and_unmapping_nodes_bloc.dart';
import '../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../../water_fertilizer_settings/presentation/bloc/water_fertilizer_setting_bloc.dart';
import '../../water_fertilizer_settings/presentation/pages/list_of_zone_set.dart';
import '../../water_fertilizer_settings/utils/water_fertilizer_settings_routes.dart';
import '../presentation/cubit/program_tab_cubit.dart';
import '../presentation/pages/program_app_bar.dart';

class ProgramTabRoutes {
  static const String programPage = "/programPage";
}

final programTabRoutesGoRoutes = [
  ShellRoute(
      builder: (context, state, child){
        return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<ProgramTabCubit>()),
              BlocProvider(
                create: (context)=> di.sl<WaterFertilizerSettingBloc>()
              )
            ],
            child: ProgramAppBar(child: child)
        );
      },
      routes: [
        getProgram(WaterFertilizerSettingsRoutes.program),
      ]
  ),
  ...waterFertilizerSettingsForZoneSetGoRoutes
];

GoRoute getProgram(String appRouteString){
  return GoRoute(
      path: appRouteString,
      builder: (context, state){
        return ListOfZoneSet();
      }
  );
}