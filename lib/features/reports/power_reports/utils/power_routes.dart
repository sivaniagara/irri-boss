import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/di/injection.dart' as di;
import '../presentation/bloc/date_tab_cubit.dart';
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
      '&toDate=%27:toDate%27&sum=:sum';
 }

/// GoRouter config
final PowerGraphRoutes = <GoRoute>[
  GoRoute(
    path: PowerGraphPageRoutes.PowerGraphPage,
    name: 'PowerGraphPage',
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      final queryParams = state.uri.queryParameters;

      final int userId = int.tryParse(extra['userId']?.toString() ?? queryParams['userId'] ?? '0') ?? 0;
      final int subuserId = int.tryParse(extra['subUserId']?.toString() ?? queryParams['subUserId'] ?? '0') ?? 0;
      final int controllerId = int.tryParse(extra['controllerId']?.toString() ?? queryParams['controllerId'] ?? '0') ?? 0;

      final String fromDate = extra['fromDate']?.toString() ??
          DateFormat('yyyy-MM-dd').format(DateTime.now());

      final String toDate = extra['toDate']?.toString() ??
          DateFormat('yyyy-MM-dd').format(DateTime.now());

     return  MultiBlocProvider(
      providers: [
        BlocProvider<PowerGraphBloc>(
          create: (_) => di.sl<PowerGraphBloc>()
            ..add(
              FetchPowerGraphEvent(
                userId: userId,
                subuserId: subuserId,
                controllerId: controllerId,
                fromDate: fromDate,
                toDate: toDate,
                sum: 0,
              ),
            ),
        ),
      BlocProvider(create: (_) => DateTabCubit()),
      ],
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
