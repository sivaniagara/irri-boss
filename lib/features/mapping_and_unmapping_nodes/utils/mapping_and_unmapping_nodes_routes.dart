import '../../../core/di/injection.dart' as di;
import '../../controller_settings/utils/controller_settings_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../dashboard/presentation/cubit/controller_context_cubit.dart';
import '../presentation/bloc/mapping_and_unmapping_nodes_bloc.dart';
import '../presentation/pages/mapping_and_unmapping_page.dart';

class MappingAndUnmappingNodesRoutes {
  static const String nodeSetting = "/nodeSetting";
}


final mappingAndUnmappingNodesGoRoutes = [
  GoRoute(
      path: MappingAndUnmappingNodesRoutes.nodeSetting,
      builder: (context, state){
        final controllerContext = (context.read<ControllerContextCubit>().state as ControllerContextLoaded);
        return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context)=> di.sl<MappingAndUnmappingNodesBloc>()..add(
                    FetchMappingAndUnmappingEvent(
                        userId: controllerContext.userId,
                        controllerId: controllerContext.controllerId,
                        deviceId: controllerContext.deviceId,
                    )
                ),
              ),
            ],
            child: MappingAndUnmappingPage()
        );
      }
  ),
];

