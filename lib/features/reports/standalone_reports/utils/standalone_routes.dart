import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/presentation/pages/motor_cyclic_page.dart';
import '../../../../../core/di/injection.dart' as di;
import '../presentation/bloc/standalone_bloc.dart';
import '../presentation/bloc/standalone_bloc_event.dart';
import '../presentation/pages/standalone_page.dart';

/// Page Route Name Constants
abstract class StandaloneReportPageRoutes {
  static const String Standalonepage = '/Standalone';
}

/// API URL Pattern
class StandaloneReportPageUrls {
  static const String getStandaloneUrl =
      'user/:userId/subuser/:subuserId/controller/:controllerId/report?&fromDate=:fromDate'
      '&toDate=:toDate&type=standalone';
 }
/// GoRouter config
final StandaloneRoutes = <GoRoute>[
  GoRoute(
    path: StandaloneReportPageRoutes.Standalonepage,
    name: 'Standalone',
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
        BlocProvider<StandaloneBloc>(
          create: (_) => di.sl<StandaloneBloc>()
            ..add(
              FetchStandaloneEvent(
                userId: userId,
                subuserId: subuserId,
                controllerId: controllerId,
                fromDate: fromDate,
                toDate: toDate,
              ),
            ),
        ),

       ],
         child: StandaloneReportPage(
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
