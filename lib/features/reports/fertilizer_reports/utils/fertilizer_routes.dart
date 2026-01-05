import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart' as di;
 import '../presentation/bloc/fertilizer_bloc.dart';
import '../presentation/bloc/fertilizer_bloc_event.dart';
import '../presentation/pages/fertilizer_page.dart';


/// Page Route Name Constants
abstract class FertilizerPageRoutes {
  static const String Fertilizerpage = '/Fertilizer';
}

/// API URL Pattern
class FertilizerPageUrls {
  static const String getFertilizerUrl =
      'user/:userId/subuser/:subuserId/controller/:controllerId/report?&fromDate=%27:fromDate%27'
      '&toDate=%27:toDate%27&type=fertpumpruntime';
 }
 /// GoRouter config
final fertilizerRoutes = <GoRoute>[
  GoRoute(
    path: FertilizerPageRoutes.Fertilizerpage,
    name: 'Fertilizer',
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
        BlocProvider<FertilizerBloc>(
          create: (_) => di.sl<FertilizerBloc>()
            ..add(
              FetchFertilizerEvent(
                userId: userId,
                subuserId: subuserId,
                controllerId: controllerId,
                fromDate: fromDate,
                toDate: toDate,
              ),
            ),
        ),

       ],
         child: FertilizerPage(
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
