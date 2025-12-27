import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart' as di;
import '../presentation/bloc/voltage_bloc.dart';
 import '../presentation/bloc/voltage_bloc_event.dart';
import '../presentation/pages/voltagegraphPage.dart';

/// Page Route Name Constants
abstract class VoltGraphPageRoutes {
  static const String voltGraphPage = '/voltageGraph';
}

/// API URL Pattern
class VoltGraphPageUrls {
  static const String getVoltGraphUrl =
      'user/:userId/subuser/:subuserId/controller/:controllerId/report'
      '?fromDate=%27:fromDate%27'
      '&toDate=%27:toDate%27'
      '&type=dripdata';
  // static const String getVoltGraphUrl =
  //     'user/:userId/subuser/:subuserId/controller/:controllerId/report'
  //     '?fromDate=:fromDate&toDate=:toDate&type=voltage';
}

/// GoRouter config
final voltGraphRoutes = <GoRoute>[
  GoRoute(
    path: VoltGraphPageRoutes.voltGraphPage,
    name: 'VoltGraphPage',
    builder: (context, state) {
      /// Safe param extraction
      final params = state.extra as Map<String, dynamic>? ?? {};

      final int userId = params['userId'] ?? 0;
      final int subuserId = params['subuserId'] ?? 0;
      final int controllerId = params['controllerId'] ?? 0;

      final String fromDate = params['fromDate'] ??
          DateFormat('yyyy-MM-dd').format(DateTime.now());

      final String toDate = params['toDate'] ??
          DateFormat('yyyy-MM-dd').format(DateTime.now());

      return BlocProvider(
        create: (_) => di.sl<VoltageGraphBloc>()
          ..add(
            FetchVoltageGraphEvent(
              userId: userId,
              subuserId: subuserId,
              controllerId: controllerId,
              fromDate: fromDate,
              toDate: toDate,
            ),
          ),
        child: VoltageGraphPage(
          userId: userId,
          subuserId: subuserId,
          controllerId: controllerId,
          fromDate: fromDate,
          toDate: toDate,
        ),
      );
    },
  ),
];
