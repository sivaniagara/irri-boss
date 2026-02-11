

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart' as di;
import '../presentation/bloc/moisture_bloc.dart';
import '../presentation/bloc/moisture_bloc_event.dart';
import '../presentation/pages/moisture_page.dart';

/// Page Route Name Constants
abstract class MoistureReportPageRoutes {
  static const String Moisturepage = '/Moisture';
}

/// API URL Pattern
class MoistureReportPageUrls {
  static const String getMoistureUrl =
      'user/:userId/subuser/:subuserId/controller/:controllerId/most';
 }
/// GoRouter config
final moistureRoutes = <GoRoute>[
  GoRoute(
    path: MoistureReportPageRoutes.Moisturepage,
    name: 'Moisture',
    builder: (context, state) {
      /// Safe param extraction
      final params = state.extra as Map<String, dynamic>? ?? {};

      final int userId = params['userId'] ?? 0;
      final int subuserId = params['subuserId'] ?? 0;
      final int controllerId = params['controllerId'] ?? 0;
      // final int userId = 7215;
      // final int subuserId = 0;
      // final int controllerId = 16032;

     return  MultiBlocProvider(
      providers: [
        BlocProvider<MoistureBloc>(
          create: (_) => di.sl<MoistureBloc>()
            ..add(
              FetchMoistureEvent(
                userId: userId,
                subuserId: subuserId,
                controllerId: controllerId,
              ),
            ),
        ),

       ],
         child: MoistureReportPage(
           userId: userId,
           subuserId: subuserId,
           controllerId: controllerId,
          ),
      );
    },
  ),
];
