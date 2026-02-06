import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/presentation/pages/mapping_and_unmapping_page.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/utils/mapping_and_unmapping_nodes_routes.dart';
import '../../../core/di/injection.dart' as di;
import '../../mapping_and_unmapping_nodes/presentation/bloc/mapping_and_unmapping_nodes_bloc.dart';
import '../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../../program_settings/utils/program_settings_routes.dart';
import '../presentation/cubit/controller_tab_cubit.dart';
import '../presentation/pages/controller_app_bar.dart';
import '../../program_settings/presentation/pages/controller_program.dart';

class ControllerSettingsRoutes {
  static const String controllerSettings = "/controllerSettings";
  static const String controllerDetails = "$controllerSettings/controllerDetails";
}

final controllerSettingGoRoutes = [
  ShellRoute(
      builder: (context, state, child){
        return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => di.sl<ControllerTabCubit>()),
            ],
            child: ControllerAppBar(child: child)
        );
      },
      routes: [
        GoRoute(
          path: ControllerSettingsRoutes.controllerDetails,
          builder: (context, state) => Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xffC6DDFF),
                    Color(0xff67C8F1),
                    Color(0xff6DA8F5),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
            ),
          ),
        ),
        GoRoute(
            path: MappingAndUnmappingNodesRoutes.nodeSetting,
            builder: (context, state){
              final controllerContext = (context.read<ControllerContextCubit>().state as ControllerContextLoaded);
              return MultiBlocProvider(
                  providers: [
                    BlocProvider(
                      create: (context)=> di.sl<MappingAndUnmappingNodesBloc>()..add(FetchMappingAndUnmappingEvent(userId: controllerContext.userId, controllerId: controllerContext.controllerId)),
                    ),
                  ],
                  child: MappingAndUnmappingPage()
              );
            }
        ),
        GoRoute(
          path: ProgramSettingsRoutes.program,
          builder: (context, state) {
            return ControllerProgram();
          },
          routes: [

          ]
        ),
      ]
  ),
];