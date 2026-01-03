import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/presentation/cubit/shared_devices_cubit.dart';

import '../../../core/di/injection.dart';
import '../../../core/widgets/glassy_wrapper.dart';
import '../../dashboard/utils/dashboard_routes.dart';

class DealerRoutes {
  static const String dealerDashboard = "/dealerDashboard";
  static const String serviceRequest = "/serviceRequest";
  static const String sellingDevice = "/sellingDevice";
  static const String customerDevice = "/customerDevice";
  static const String sharedDevice = "/sharedDevice";
  static const String selectedCustomer = "/selectedCustomer";
}

final dealerRoutes = <GoRoute>[
  GoRoute(
    path: DealerRoutes.sharedDevice,
    builder: (context, state) {
      final params = state.uri.queryParameters as Map<String, dynamic>;
      return BlocProvider<SharedDevicesCubit>(
          create: (_) => sl<SharedDevicesCubit>()..getSharedDevices(params['userId']),
        child: BlocListener<SharedDevicesCubit, SharedDevicesState>(
          listener: (context, state) {
            if (state is SharedDevicesLoaded && state.sharedDevices.isNotEmpty) {
              final userId = state.sharedDevices[1].userId.toString();
              context.push(
                '${DashBoardRoutes.dashboard}?userId=$userId&userType=2',
              );
            }
          },
          child: const GlassyWrapper(
            child: Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          ),
        ),
      );
    },
  ),
];