import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
 import '../../../../../core/di/injection.dart' as di;
import '../presentation/bloc/flow_graph_bloc.dart';
import '../presentation/bloc/flow_graph_bloc_event.dart';
import '../presentation/pages/flow_graph_page.dart';


 

/// Page Route Name Constants
abstract class FlowGraphPageRoutes {
  static const String FlowGraphpage = '/FlowGraph';
}

class FlowGraphPageUrls {
  static const String getFlowGraphUrl = "user/:userId/subuser/:subuserId/controller/:controllerId/report?fromDate=':fromDate'&toDate=':toDate'&type=dripdatadaywise";

}
/// API URL Pattern
// class FlowGraphPageUrls {
//   static const String getFlowGraphUrl =
//       'user/:userId/subuser/:subuserId/controller/:controllerId/report?&fromDate=:fromDate&toDate=:toDate&type=FlowGraph';
//   //report?&fromDate=2025-12-18&toDate=2025-12-24&type=FlowGraph
//  }
 /// GoRouter config
final FlowGraphRoutes = <GoRoute>[
  GoRoute(
    path: FlowGraphPageRoutes.FlowGraphpage,
    name: 'FlowGraph',
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





     return  MultiBlocProvider(
      providers: [
        BlocProvider<FlowGraphBloc>(
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
        ),

       ],
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
