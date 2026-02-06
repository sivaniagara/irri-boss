import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/pages/irrigation_settings_page.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/pages/template_setting_page.dart';
import 'package:niagara_smart_drip_irrigation/features/valve_flow_settings/presentation/pages/valve_flow_page.dart';
import 'package:niagara_smart_drip_irrigation/features/valve_flow_settings/presentation/bloc/valve_flow_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/valve_flow_settings/presentation/bloc/valve_flow_event.dart';
import '../../../core/di/injection.dart' as di;
import '../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../../progam_zone_set/utils/program_tab_routes.dart';
import '../../water_fertilizer_settings/presentation/bloc/water_fertilizer_setting_bloc.dart';
import '../presentation/bloc/template_irrigation_settings_bloc.dart';
import '../presentation/enums/irrigation_settings_enum.dart';

class IrrigationSettingsRoutes {
  static const String irrigationSettings = "/irrigationSettings";
  static const String templateSetting = "/templateSetting/:settingName/:settingNo";
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
        ...programTabRoutesGoRoutes,
        GoRoute(
            path: IrrigationSettingsRoutes.templateSetting,
            builder: (context, state) {
              var settingName = state.pathParameters['settingName']!;
              var settingNo = state.pathParameters['settingNo']!;
              final controllerContext = (context.read<ControllerContextCubit>().state as ControllerContextLoaded);

              if (settingNo == IrrigationSettingsEnum.valveFlow.settingId.toString()) {
                return BlocProvider(
                  create: (context) => di.sl<ValveFlowBloc>()..add(
                    FetchValveFlowDataEvent(
                      userId: controllerContext.userId,
                      controllerId: controllerContext.controllerId,
                      subUserId: controllerContext.subUserId, deviceId: '',
                    )
                  ),
                  child: const ValveFlowPage(),
                );
              }

              return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context)=> di.sl<TemplateIrrigationSettingsBloc>()..add(
                          FetchTemplateSettingEvent(
                              userId: controllerContext.userId,
                              controllerId: controllerContext.controllerId,
                              subUserId: controllerContext.subUserId,
                              settingNo: settingNo, deviceId: controllerContext.deviceId
                          )
                      ),
                    )
                  ],
                  child: TemplateSettingPage(appBarTitle: settingName)
              );
            },
        ),
      ]
  ),
];