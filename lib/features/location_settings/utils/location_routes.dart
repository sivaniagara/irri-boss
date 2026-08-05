import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/route_constants.dart';
import '../presentation/cubit/location_cubit.dart';
import '../presentation/pages/set_location_page.dart';

final locationRoutes = [
  GoRoute(
    path: RouteConstants.setLocationPage,
    builder: (context, state) {
      final extras = state.extra as Map<String, dynamic>;
      final int userId = extras['userId'];
      final int controllerId = extras['controllerId'];
      final String? initialLatLong = extras['initialLatLong'];

      return BlocProvider(
        create: (context) => sl<LocationCubit>(),
        child: SetLocationPage(
          userId: userId,
          controllerId: controllerId,
          initialLatLong: initialLatLong,
        ),
      );
    },
  ),
];
