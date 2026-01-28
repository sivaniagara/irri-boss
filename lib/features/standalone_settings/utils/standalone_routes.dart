import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injection.dart' as di;
import '../../dashboard/utils/dashboard_routes.dart';
import '../presentation/bloc/standalone_bloc.dart';
import '../presentation/bloc/standalone_event.dart';
import '../presentation/pages/standalone_page.dart';
import '../presentation/pages/configuration_page.dart';

abstract class StandaloneRoutes {
  static const String standalone = DashBoardRoutes.standalone;
  static const String configuration = DashBoardRoutes.configuration;
}

final standaloneRoutes = <GoRoute>[
  GoRoute(
    path: 'standalone',
    builder: (context, state) {
      final params = state.extra as Map<String, dynamic>;
      final userId = params["userId"]?.toString() ?? '';
      final controllerId = params["controllerId"]?.toString() ?? '';
      final deviceId = params["deviceId"]?.toString() ?? '';
      final subUserId = params["subUserId"]?.toString() ?? '0';

      return BlocProvider.value(
        value: di.sl<StandaloneBloc>(),
        child: Builder(
          builder: (context) {
            final bloc = context.read<StandaloneBloc>();
            if (bloc.state is StandaloneInitial) {
              bloc.add(FetchStandaloneDataEvent(
                  userId: userId,
                  controllerId: controllerId,
                  deviceId: deviceId,
                  subUserId: subUserId
              ));
            }
            return StandalonePage(data: params);
          },
        ),
      );
    },
  ),
  GoRoute(
    path: 'standalone/configuration',
    builder: (context, state) {
      final params = state.extra as Map<String, dynamic>;
      return BlocProvider.value(
        value: di.sl<StandaloneBloc>(),
        child: ConfigurationPage(data: params),
      );
    },
  ),
];
