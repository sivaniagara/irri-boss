import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/injection.dart' as di;
import '../presentation/bloc/get_moisture_status_bloc.dart';
import '../presentation/bloc/get_moisture_status_event.dart';
import '../presentation/pages/get_moisture_status_page.dart';

abstract class GetMoistureNodeStatusRoutes {
  static const String nodeMoistureStatusPage = '/nodeMoistureStatus';
}

class NodeStatusUrls {
  static const String getNodeStatusUrl =
      'user/:userId/subuser/:subuserId/controller/:controllerId/report?fromDate=:fromDate&toDate=:toDate&type=nodedata';
}

final nodeMoistureStatusRoutes = <GoRoute>[
  GoRoute(
    path: GetMoistureNodeStatusRoutes.nodeMoistureStatusPage,
    name: 'nodeMoistureStatus',
    builder: (context, state) {
      final params = state.extra as Map<String, dynamic>? ?? {};
      final int userId = params['userId'] ?? 0;
      final int subuserId = params['subuserId'] ?? 0;
      final int controllerId = params['controllerId'] ?? 0;
      final String fromDate = params['fromDate'] ?? '';
      final String toDate = params['toDate'] ?? '';

      return BlocProvider<GetMoistureStatusBloc>(
        create: (_) => di.sl<GetMoistureStatusBloc>()
          ..add(
            FetchGetMoistureStatus(
              userId: userId,
              subuserId: subuserId,
              controllerId: controllerId,
              fromDate: fromDate,
              toDate: toDate,
            ),
          ),
        child: NodeStatusPage(
          userId: userId,
          subuserId: subuserId,
          controllerId: controllerId,
        ),
      );
    },
  ),
];
