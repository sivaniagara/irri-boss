import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/widgets/glassy_wrapper.dart';

import '../../../dashboard/utils/dashboard_routes.dart';
import '../cubit/shared_devices_cubit.dart';

class SharedDevicesPage extends StatelessWidget {
  const SharedDevicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassyWrapper(
      child: Scaffold(
        appBar: AppBar(title: const Text('Shared Devices')),
        body: BlocBuilder<SharedDevicesCubit, SharedDevicesState>(
          builder: (context, state) {
            if (state is SharedDevicesInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SharedDevicesError) {
              return Center(
                child: Text('Error: ${state.message}'),
              );
            }

            if (state is SharedDevicesLoaded) {
              final sharedControllers = state.sharedDevices;

              if (sharedControllers.isEmpty) {
                return const Center(
                  child: Text('No shared devices found.'),
                );
              }

              return ListView.builder(
                itemCount: sharedControllers.length,
                itemBuilder: (context, index) {
                  final controller = sharedControllers[index];
                  return ListTile(
                    title: Text(controller.deviceName),
                    subtitle: Text('Owner: ${controller.userName}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context.push(
                        '${DashBoardRoutes.dashboard}?userId=${controller.userId}&userType=2&groupId=${controller.groupId}',
                        extra: {
                          'forcedControllerId': controller.userDeviceId,
                        },
                      );
                    },
                  );
                },
              );
            }

            return const Center(child: Text('Tap a tab to load devices'));
          },
        ),
      ),
    );
  }
}