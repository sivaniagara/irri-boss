import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
 /// GoRouter config
final ZoneDurationRoutes = <GoRoute>[
  GoRoute(
    path: ZoneDurationPageRoutes.ZoneDurationpage,
    name: 'ZoneDuration',
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
