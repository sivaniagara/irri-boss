import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/injection.dart' as di;
import '../presentation/bloc/power_bloc.dart';
import '../presentation/bloc/power_bloc_event.dart';
import '../presentation/pages/powergraphPage.dart';



/// Page Route Name Constants
abstract class PowerGraphPageRoutes {
  static const String PowerGraphPage = '/PowerGraph';
}

/// API URL Pattern
class PowerGraphPageUrls {
  static const String getPowerGraphUrl =
      'user/:userId/subuser/:subuserId/controller/:controllerId/powerandmotor?fromDate=%27:fromDate%27'
      '&toDate=%27:toDate%27';
 }

/// GoRouter config
final PowerGraphRoutes = <GoRoute>[
  GoRoute(
    path: PowerGraphPageRoutes.PowerGraphPage,
    name: 'PowerGraphPage',
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
        create: (_) => di.sl<PowerGraphBloc>()
          ..add(
            FetchPowerGraphEvent(
              userId: userId,
              subuserId: subuserId,
              controllerId: controllerId,
              fromDate: fromDate,
              toDate: toDate,
            ),
          ),
        child: PowerGraphPage(
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
