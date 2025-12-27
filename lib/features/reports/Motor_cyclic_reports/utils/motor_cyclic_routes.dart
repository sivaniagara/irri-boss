import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/presentation/pages/motor_cyclic_page.dart';
import '../../../../../core/di/injection.dart' as di;
import '../presentation/bloc/motor_cyclic_bloc.dart';
import '../presentation/bloc/motor_cyclic_bloc_event.dart';
import '../presentation/bloc/motor_cyclic_mode.dart';




/// Page Route Name Constants
abstract class MotorCyclicPageRoutes {
  static const String MotorCyclicpage = '/MotorCyclic';
}

/// API URL Pattern
class MotorCyclicPageUrls {
  static const String getMotorCyclicUrl =
      'user/:userId/subuser/:subuserId/controller/:controllerId/report?&fromDate=:fromDate'
      '&toDate=:toDate&type=motorcyclic';
 }
/// GoRouter config
final MotorCyclicRoutes = <GoRoute>[
  GoRoute(
    path: MotorCyclicPageRoutes.MotorCyclicpage,
    name: 'MotorCyclic',
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
        BlocProvider<MotorCyclicBloc>(
          create: (_) => di.sl<MotorCyclicBloc>()
            ..add(
              FetchMotorCyclicEvent(
                userId: userId,
                subuserId: subuserId,
                controllerId: controllerId,
                fromDate: fromDate,
                toDate: toDate,
              ),
            ),
        ),
        BlocProvider(
          create: (_) => MotorCyclicViewCubit(),
        ),
       ],
         child: MotorCyclicPage(
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
