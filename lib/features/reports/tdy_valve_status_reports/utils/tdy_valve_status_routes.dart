import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/tdy_valve_status_reports/presentation/bloc/tdy_valve_mode.dart';
import '../../../../../core/di/injection.dart' as di;
import '../presentation/bloc/tdy_valve_status_bloc.dart';
import '../presentation/bloc/tdy_valve_status_bloc_event.dart';
import '../presentation/pages/tdy_valve_status_page.dart';
 

/// Page Route Name Constants
abstract class TdyValveStatusPageRoutes {
  static const String TdyValveStatuspage = '/TdyValveStatus';
}

/// API URL Pattern
class TdyValveStatusPageUrls {
  static const String getTdyValveStatusUrl =
      'user/:userId/subuser/:subuserId/controller/:controllerId/zone/graph?&fromDate=:fromDate'
      '&programName=p:program';
 }
 /// GoRouter config
final TdyValveStatusRoutes = <GoRoute>[
  GoRoute(
    path: TdyValveStatusPageRoutes.TdyValveStatuspage,
    name: 'TdyValveStatus',
    builder: (context, state) {
      /// Safe param extraction
      final params = state.extra as Map<String, dynamic>? ?? {};

      // final int userId = params['userId'] ?? 0;
      // final int subuserId = params['subuserId'] ?? 0;
      // final int controllerId = params['controllerId'] ?? 0;
      // final String fromDate = params['fromDate'] ??
      //     DateFormat('yyyy-MM-dd').format(DateTime.now());
      // final String program = "1";

//http://3.1.62.165:8080/api/v1/user/2489/subuser/0/controller/3827/zone/graph?&fromDate=2026-02-09&programName=p2
       final int userId = 2489;
      final int subuserId = 0;
      final int controllerId = 3827;
      final String fromDate = '2026-02-09';
      final String program = '2';

     return  MultiBlocProvider(
      providers: [
        BlocProvider<TdyValveStatusBloc>(
          create: (_) => di.sl<TdyValveStatusBloc>()
            ..add(
              FetchTdyValveStatusEvent(
                userId: userId,
                subuserId: subuserId,
                controllerId: controllerId,
                fromDate: fromDate,
                program: program,
              ),
            ),
        ),
        BlocProvider(
          create: (_) => TdyValveStatusCubit(),
        ),
       ],
         child: TdyValveStatusPage(
           userId: userId,
           subuserId: subuserId,
           controllerId: controllerId,
           fromDate: fromDate,
           program: program,
          ),
      );
    },
  ),
];
