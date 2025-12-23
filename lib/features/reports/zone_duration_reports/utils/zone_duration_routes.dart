import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/presentation/pages/motor_cyclic_page.dart';
import '../../../../../core/di/injection.dart' as di;
import '../presentation/bloc/zone_duration_bloc.dart';
import '../presentation/bloc/zone_duration_bloc_event.dart';
import '../presentation/pages/zone_duration_page.dart';
 




/// Page Route Name Constants
abstract class ZoneDurationPageRoutes {
  static const String ZoneDurationpage = '/ZoneDuration';
}

/// API URL Pattern
class ZoneDurationPageUrls {
  static const String getZoneDurationUrl =
      'user/:userId/subuser/:subuserId/controller/:controllerId/report?&fromDate=:fromDate'
      '&toDate=:toDate&type=zoneruntime';
 }
 //http://3.1.62.165:8080/api/v1/user/2411/subuser/0/controller/4985/report?&fromDate='2025-12-22'&toDate='2025-12-22'&type=zoneruntime
/// GoRouter config
final ZoneDurationRoutes = <GoRoute>[
  GoRoute(
    path: ZoneDurationPageRoutes.ZoneDurationpage,
    name: 'ZoneDuration',
    builder: (context, state) {
      /// Safe param extraction
      final params = state.extra as Map<String, dynamic>? ?? {};

      // final int userId = params['userId'] ?? 0;
      // final int subuserId = params['subuserId'] ?? 0;
      // final int controllerId = params['controllerId'] ?? 0;
      // final String fromDate = params['fromDate'] ??
      //     DateFormat('yyyy-MM-dd').format(DateTime.now());
      // final String toDate = params['toDate'] ??
      //     DateFormat('yyyy-MM-dd').format(DateTime.now());
      final int userId = 2411;
      final int subuserId = 0;
      final int controllerId = 4985;
      final String fromDate = '2025-12-22';
      final String toDate = '2025-12-22';

     return  MultiBlocProvider(
      providers: [
        BlocProvider<ZoneDurationBloc>(
          create: (_) => di.sl<ZoneDurationBloc>()
            ..add(
              FetchZoneDurationEvent(
                userId: userId,
                subuserId: subuserId,
                controllerId: controllerId,
                fromDate: fromDate,
                toDate: toDate,
              ),
            ),
        ),

       ],
         child: ZoneDurationPage(
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
