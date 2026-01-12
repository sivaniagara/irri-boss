import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/controller_context_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/presentation/pages/edit_program_page.dart';

import '../../../core/di/injection.dart' as di;
import '../presentation/bloc/edit_program_bloc.dart';


class EditProgramRoutes {
  static const String program = "/program";
}

final editProgramGoRoutes = [
  GoRoute(
      path: EditProgramRoutes.program,
      builder: (context, state) {
        final programId = state.uri.queryParameters['programId'];
        final controllerContext = context.read<ControllerContextCubit>().state as ControllerContextLoaded;
        return BlocProvider(
            create: (_) => di.sl<EditProgramBloc>()..add(
                GetProgramEvent(
                    userId: controllerContext.userId,
                    controllerId: controllerContext.controllerId,
                    subUserId: controllerContext.subUserId,
                    programId: int.parse(programId.toString()),
                    deviceId: controllerContext.deviceId
                )
            ),
            child: EditProgramPage());
      },
      routes: [

      ]
  ),
];