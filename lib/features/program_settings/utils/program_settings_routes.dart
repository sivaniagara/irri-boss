import 'package:niagara_smart_drip_irrigation/features/common_id_settings/presentation/bloc/common_id_settings_event.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/presentation/pages/common_id_setting_page.dart';

import '../../../core/di/injection.dart' as di;
import '../../controller_settings/utils/controller_settings_routes.dart';
import '../../common_id_settings/presentation/bloc/common_id_settings_bloc.dart';
import '../sub_module/edit_zone/presentation/bloc/edit_zone_bloc.dart';
import '../sub_module/edit_zone/presentation/pages/edit_zone_page.dart';
import '../../dashboard/presentation/cubit/controller_context_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/bloc/program_bloc.dart';

class ProgramSettingsRoutes {
  static const String program = "${ControllerSettingsRoutes.controllerSettings}/programDetails";
  static const String editZone = "/editZone/:programId/:zoneSerialNo";
  static const String commonIdSettings = "/commonIdSettings";
}

final programSettingsGoRoutes = [
  GoRoute(
      path: ProgramSettingsRoutes.editZone,
      builder: (context, state){
        final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;
        final progId = state.pathParameters['programId']!;
        final zoneSerialNo = state.pathParameters['zoneSerialNo'];
        print("zoneSerialNo => ${zoneSerialNo}");

        late EditZoneEvent editZoneEvent;
        if(zoneSerialNo == ':zoneSerialNo'){
          editZoneEvent = AddZone(userId: controllerContext.userId, controllerId: controllerContext.controllerId, programId: progId);
        }else{
          editZoneEvent = EditZone(userId: controllerContext.userId, controllerId: controllerContext.controllerId, programId: progId, zoneSerialNo: zoneSerialNo!);
        }
        return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context)=> di.sl<EditZoneBloc>()..add(editZoneEvent),
              ),
              BlocProvider.value(value: context.read<ProgramBloc>())
            ],
            child: EditZonePage()
        );
      }
  ),
  GoRoute(
      path: ProgramSettingsRoutes.commonIdSettings,
      builder: (context, state){
        final controllerContext = (context.read<ControllerContextCubit>().state as ControllerContextLoaded);
        return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context)=> di.sl<CommonIdSettingsBloc>()..add(FetchCommonIdSettings(userId: controllerContext.userId, controllerId: controllerContext.controllerId)),
              ),
              BlocProvider.value(value: context.read<ProgramBloc>())
            ],
            child: CommonIdSettingPage()
        );
      }
  ),
];