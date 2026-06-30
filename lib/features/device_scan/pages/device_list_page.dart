import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/device_scan/data/model/device_model.dart';
import 'package:niagara_smart_drip_irrigation/features/device_scan/pages/qr_scanner_page.dart';
import '../../auth/presentation/bloc/auth_bloc.dart';
import '../../auth/presentation/bloc/auth_state.dart';
import '../../dashboard/utils/dashboard_routes.dart';
import '../../dealer_dashboard/utils/dealer_routes.dart';
import '../bloc/device_bloc.dart';
import '../bloc/device_event.dart';
import '../bloc/device_state.dart';

class QRDeviceListPage extends StatefulWidget {
  const QRDeviceListPage({super.key});

  @override
  State<QRDeviceListPage> createState() => _QRDeviceListPageState();
}

class _QRDeviceListPageState extends State<QRDeviceListPage> {
  bool _hasAutoOpenedScanner = false;

  void _navigateHome() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final userId = authState.user.userDetails.id;
      final userType = authState.user.userDetails.userType;
      final route = userType == 2 ? DealerRoutes.dealerDashboard : DashBoardRoutes.dashboard;
      context.go('$route?userId=$userId&userType=$userType');
    } else {
      context.go('/');
    }
  }

  Future<void> _openScanner() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const QrScannerPage(),
      ),
    );

    if (result != null && mounted) {
      context.read<QRDeviceBloc>().add(
            AddScannedDevice(result),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _navigateHome();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Add Devices"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigateHome,
          ),
        ),
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              heroTag: "send",
              child: const Icon(Icons.send),
              onPressed: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  final userId = authState.user.userDetails.id;
                  context.read<QRDeviceBloc>().add(SendDevices(userId));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("User not authenticated")),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            FloatingActionButton(
              heroTag: "scan",
              child: const Icon(Icons.document_scanner_outlined),
              onPressed: _openScanner,
            ),
          ],
        ),
        body: BlocConsumer<QRDeviceBloc, DeviceState>(
          listener: (context, state) {
            if (state is DeviceError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }

            // Auto-open scanner if list is empty and we haven't auto-opened yet
            if (state is DeviceLoaded && state.devices.isEmpty && !_hasAutoOpenedScanner) {
              setState(() {
                _hasAutoOpenedScanner = true;
              });
              _openScanner();
            }
          },
          builder: (context, state) {
            if (state is DeviceLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is DeviceLoaded) {
              if (state.devices.isEmpty) {
                return const Center(
                  child: Text("No devices found in the list. Scan to add a new device"),
                );
              }

              return ListView.builder(
                itemCount: state.devices.length,
                itemBuilder: (_, index) {
                  final item = state.devices[index];

                  return Card(
                    child: ListTile(
                      title: Text(item.deviceId),
                      subtitle: Text("BLE Pump - ${_getStatusText(item.status)}"),
                      leading: Text("${index + 1}."),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.manufactureDate),
                          const SizedBox(width: 8),
                          _getStatusIcon(item.status),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  String _getStatusText(UploadStatus status) {
    switch (status) {
      case UploadStatus.pending:
        return "Pending";
      case UploadStatus.success:
        return "Success";
      case UploadStatus.failed:
        return "Failed";
      case UploadStatus.alreadyExists:
        return "Already Insert";
    }
  }

  Widget _getStatusIcon(UploadStatus status) {
    switch (status) {
      case UploadStatus.pending:
        return const Icon(Icons.pending_outlined, color: Colors.orange);
      case UploadStatus.success:
        return const Icon(Icons.check_circle_outline, color: Colors.green);
      case UploadStatus.failed:
        return const Icon(Icons.error_outline, color: Colors.red);
      case UploadStatus.alreadyExists:
        return const Icon(Icons.info_outline, color: Colors.blue);
    }
  }
}
