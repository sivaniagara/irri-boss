import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
 import '../../../../../core/di/injection.dart' as di;
import '../presentation/bloc/zone_cyclic_bloc.dart';
import '../presentation/bloc/zone_cyclic_bloc_event.dart';
import '../presentation/bloc/zone_cyclic_mode.dart';
import '../presentation/pages/zone_cyclic_page.dart';

 

/// Page Route Name Constants
abstract class ZoneCyclicPageRoutes {
  static const String ZoneCyclicpage = '/ZoneCyclic';
}

/// API URL Pattern
class ZoneCyclicPageUrls {
  static const String getZoneCyclicUrl =
      'user/:userId/subuser/:subuserId/controller/:controllerId/report?&fromDate=:fromDate&toDate=:toDate&type=zonecyclic';
  //report?&fromDate=2025-12-18&toDate=2025-12-24&type=zonecyclic
 }
 /// GoRouter config
final ZoneCyclicRoutes = <GoRoute>[
  GoRoute(
    path: ZoneCyclicPageRoutes.ZoneCyclicpage,
    name: 'ZoneCyclic',
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
      final String fromDate = '2025-12-24';
      final String toDate = '2025-12-24';

     return  MultiBlocProvider(
      providers: [
        BlocProvider<ZoneCyclicBloc>(
          create: (_) => di.sl<ZoneCyclicBloc>()
            ..add(
              FetchZoneCyclicEvent(
                userId: userId,
                subuserId: subuserId,
                controllerId: controllerId,
                fromDate: fromDate,
                toDate: toDate,
              ),
            ),
        ),
        BlocProvider(
          create: (_) => ZoneCyclicCubit(),
        ),
       ],
         child: ZoneCyclicPage(
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
