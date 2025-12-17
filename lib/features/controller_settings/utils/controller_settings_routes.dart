import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/edit_zone/presentation/bloc/edit_zone_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/edit_zone/presentation/pages/edit_zone.dart';
import '../../../core/di/injection.dart' as di;
import '../program_list/presentation/bloc/program_bloc.dart';
import '../program_list/presentation/cubit/controller_context_cubit.dart';
import '../program_list/presentation/cubit/controller_tab_cubit.dart';
import '../program_list/presentation/pages/controller_app_bar.dart';
import '../program_list/presentation/pages/controller_program.dart';

class ControllerSettingsRoutes {
  static const String controllerSettings = "/controllerSettings";
  static const String controllerDetails = "$controllerSettings/controllerDetails";
  static const String nodes = "$controllerSettings/nodesDetails";
  static const String program = "$controllerSettings/programDetails";
  static const String editZone = "/editZone/:programId";
}

final controllerSettingGoRoutes = [
  ShellRoute(
      builder: (context, state, child){
        Map<String, dynamic> params = state.extra as Map<String, dynamic>;
        print("params : $params");
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
          path: ControllerSettingsRoutes.nodes,
          builder: (context, state) => Center(child: Text('Nodes', style: TextStyle(color: Colors.black),),),
        ),
        GoRoute(
          path: ControllerSettingsRoutes.program,
          builder: (context, state) {
            final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;
            return BlocProvider(
              create: (context)=> di.sl<ProgramBloc>()..add(FetchPrograms(userId: controllerContext.userId, controllerId: controllerContext.controllerId)),
              child: ControllerProgram(),
            );
          },
          routes: [

          ]
        ),
      ]
  ),
  GoRoute(
      path: ControllerSettingsRoutes.editZone,
      builder: (context, state){
        final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;
        final progId = state.pathParameters['programId']!;
        return BlocProvider(
          create: (context)=> di.sl<EditZoneBloc>()..add(AddZone(userId: controllerContext.userId, controllerId: controllerContext.controllerId, programId: progId)),
          child: EditZone(),
        );
      }
  )
];