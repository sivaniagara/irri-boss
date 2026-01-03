import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/progam_zone_set/presentation/enums/program_tab_enum.dart';
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/presentation/pages/list_of_zone_in_zone_set.dart';
import '../../../core/di/injection.dart' as di;
import '../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../../progam_zone_set/presentation/cubit/program_tab_cubit.dart';
import '../../progam_zone_set/presentation/pages/program_app_bar.dart';
import '../../progam_zone_set/utils/program_tab_routes.dart';
import '../presentation/bloc/water_fertilizer_setting_bloc.dart';

class WaterFertilizerSettingsRoutes{
  static String program = "${ProgramTabRoutes.programPage}/:programId";
  static String zoneSet = "/zoneSetSetting/:programSettingNo/:zoneSetId";
}

final waterFertilizerSettingsForZoneSetGoRoutes = [
  GoRoute(
      path: WaterFertilizerSettingsRoutes.zoneSet,
      builder: (context, state){
        final programTabContext = (context.read<ProgramTabCubit>().state);
        final controllerContext = (context.read<ControllerContextCubit>().state as ControllerContextLoaded);
        final programSettingNo = state.pathParameters['programSettingNo'];
        final zoneSetId = state.pathParameters['zoneSetId'];
        return MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<ProgramTabCubit>()),
              BlocProvider(
                  create: (context) => di.sl<WaterFertilizerSettingBloc>()
                    ..add(
                      FetchZoneSetSettingEvent(
                          userId: controllerContext.userId,
                          controllerId: controllerContext.controllerId,
                          subUserId: controllerContext.subUserId,
                          programSettingNo: programSettingNo!,
                          zoneSetId: zoneSetId!,
                        programId: programTabContext.tab.id()
                      )),
              )
            ],
            child: ListOfZoneInZoneSet()
        );
      }
  ),
];
