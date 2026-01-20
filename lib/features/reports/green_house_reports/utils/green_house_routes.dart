import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart' as di;
import '../presentation/bloc/green_house_bloc.dart';
import '../presentation/bloc/green_house_bloc_event.dart';
import '../presentation/pages/green_house_page.dart';

abstract class GreenHouseReportPageRoutes {
  static const String greenHouseReportPage = '/GreenHouseReport';
}

final greenHouseReportRoutes = <GoRoute>[
  GoRoute(
    path: GreenHouseReportPageRoutes.greenHouseReportPage,
    name: 'GreenHouseReport',
    builder: (context, state) {
      final params = state.extra as Map<String, dynamic>? ?? {};

      final int userId = params['userId'] ?? 0;
      final int subuserId = params['subuserId'] ?? 0;
      final int controllerId = params['controllerId'] ?? 0;

      final String fromDate =
          params['fromDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      final String toDate =
          params['toDate'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

      return BlocProvider(
        create: (_) => di.sl<GreenHouseBloc>()
          ..add(
            FetchGreenHouseReportEvent(
              userId: userId,
              subuserId: subuserId,
              controllerId: controllerId,
              fromDate: fromDate,
              toDate: toDate,
            ),
          ),
        child: GreenHousePage(
          userId: userId,
          subuserId: subuserId,
          controllerId: controllerId,
        ),
      );
    },
  ),
];
