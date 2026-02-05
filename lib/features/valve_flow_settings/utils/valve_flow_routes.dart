import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../presentation/bloc/valve_flow_bloc.dart';
import '../presentation/bloc/valve_flow_event.dart';
import '../presentation/pages/valve_flow_page.dart';

class ValveFlowRoutes {
  static const String valveFlow = '/valveFlow';

  static List<GoRoute> get routes => [
        GoRoute(
          path: valveFlow,
          name: 'valveFlow',
          builder: (context, state) {
            final extras = state.extra as Map<String, dynamic>;
            final userId = extras['userId'] as String;
            final controllerId = extras['controllerId'] as String;
            final deviceId = extras['deviceId'] as String;
            final subUserId = extras['subUserId'] as String;

            return BlocProvider(
              create: (context) => sl<ValveFlowBloc>()
                ..add(FetchValveFlowDataEvent(
                  userId: userId,
                  controllerId: controllerId,
                  deviceId: deviceId,
                  subUserId: subUserId,
                )),
              child: const ValveFlowPage(),
            );
          },
        ),
      ];
}
