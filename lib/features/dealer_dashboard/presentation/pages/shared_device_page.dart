import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/presentation/cubit/shared_devices_cubit.dart';

class SharedDevicePage extends StatelessWidget {
  const SharedDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SharedDevicesCubit, SharedDevicesState>(
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
    );
  }
}