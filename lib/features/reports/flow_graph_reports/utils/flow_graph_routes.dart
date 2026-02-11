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

/// GoRouter config
final FlowGraphRoutes = <GoRoute>[
  GoRoute(
    path: FlowGraphPageRoutes.FlowGraphpage,
    name: 'FlowGraph',
    builder: (context, state) {
      /// Safe param extraction
      final params = state.extra as Map<String, dynamic>? ?? {};

      // Parse values safely since they might be passed as Strings from other pages
      final int userId = int.tryParse(params['userId']?.toString() ?? '') ?? 0;
      final int subuserId = int.tryParse(params['subuserId']?.toString() ?? '') ?? 0;
      final int controllerId = int.tryParse(params['controllerId']?.toString() ?? '') ?? 0;
      
      final String fromDate = params['fromDate'] ??
          DateFormat('yyyy-MM-dd').format(DateTime.now());
      final String toDate = params['toDate'] ??
          DateFormat('yyyy-MM-dd').format(DateTime.now());

      return MultiBlocProvider(
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
