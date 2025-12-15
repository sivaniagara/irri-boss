import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../../core/di/injection.dart' as di;
import '../program_list/presentation/bloc/program_bloc.dart';
import '../program_list/presentation/cubit/controller_tab_cubit.dart';
import '../program_list/presentation/pages/controller_app_bar.dart';
import '../program_list/presentation/pages/controller_program.dart';

class ControllerSettingsRoutes {
  static const String controllerSettings = "/controllerSettings";
  static const String controllerDetails = "$controllerSettings/controllerDetails";
  static const String nodes = "$controllerSettings/nodesDetails";
  static const String program = "$controllerSettings/programDetails";
}

final controllerSettingGoRoutes = [
  ShellRoute(
      builder: (context, state, child){
        return BlocProvider(
          create: (context) => di.sl<ControllerTabCubit>(),
          child: ControllerAppBar(child: child),
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
            Map<String, dynamic> params = state.extra as Map<String, dynamic>;
            return BlocProvider(
              create: (context)=> di.sl<ProgramBloc>()..add(FetchPrograms(params['userId'], params['controllerId'])),
              child: ControllerProgram(),
            );
          },
        ),
      ]
  ),
];