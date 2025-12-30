import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart' as di;
import '../presentation/bloc/flow_graph_bloc.dart';
import '../presentation/bloc/flow_graph_bloc_event.dart';
import '../presentation/pages/flow_graph_Page.dart';
 
/// Page Route Name Constants
abstract class FlowGraphPageRoutes {
  static const String FlowGraphPage = '/flowGraph';
}

/// API URL Pattern
class FlowGraphPageUrls {
  static const String getFlowGraphUrl = 'user/:userId/subuser/:subuserId/controller/:controllerId/report?fromDate=":fromDate"&toDate=":toDate"&type=dripdatadaywise';

}

/// GoRouter config
final FlowGraphRoutes = <GoRoute>[
  GoRoute(
    path: FlowGraphPageRoutes.FlowGraphPage,
    name: 'FlowGraphPage',
    builder: (context, state) {
      /// Safe param extraction
      final params = state.extra as Map<String, dynamic>? ?? {};

      // final int userId = params['userId'] ?? 0;
      // final int subuserId = params['subuserId'] ?? 0;
      // final int controllerId = params['controllerId'] ?? 0;
      //
      // final String fromDate = params['fromDate'] ??
      //     DateFormat('yyyy-MM-dd').format(DateTime.now());
      //
      // final String toDate = params['toDate'] ??
      //     DateFormat('yyyy-MM-dd').format(DateTime.now());

      http://3.1.62.165:8080/api/v1/user/2558/subuser/0/controller/27910/report?&fromDate='2025-12-17'&toDate='2025-12-29'&type=dripdatadaywise
      final int userId = 2558;
      final int subuserId = 0;
      final int controllerId = 27910;
      final String fromDate = '2025-12-17';
      final String toDate = '2025-12-29';



      return BlocProvider(
        create: (_) => di.sl<FlowGraphBloc>()
          ..add(
            FetchFlowGraphEvent(
              userId: userId,
              subuserId: subuserId,
              controllerId: controllerId,
              fromDate: fromDate,
              toDate: toDate,
            ),
          ),
        child: FlowGraphPage(
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
