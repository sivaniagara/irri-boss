import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ble_cubit.dart';

/// A compact banner rendered at the top of [Dashboard20] only when the
/// current controller is a WLC model (modelId == 5).
///
/// Shows scanning / connecting / connected / error status and a
/// Connect / Disconnect button.
///
/// Add it inside [Dashboard20.build] like:
///
/// ```dart
/// if (wlcModel.contains(controllerEntity.modelId))
///   BleStatusBanner(deviceId: controllerEntity.deviceId),
/// ```
class BleStatusBanner extends StatelessWidget {
  final String deviceId;

  const BleStatusBanner({super.key, required this.deviceId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BleCubit, BleState>(
      builder: (context, state) {
        final bool isConnected =
            state is BleConnected && state.deviceId == deviceId;
        final bool isBusy =
            state is BleScanning || state is BleConnecting;

        Color bannerColor;
        IconData iconData;
        String statusText;

        if (isConnected) {
          bannerColor = const Color(0xFF2E7D32); // dark green
          iconData = Icons.bluetooth_connected;
          statusText = 'BLE Connected';
        } else if (state is BleScanning) {
          bannerColor = const Color(0xFF1565C0); // blue
          iconData = Icons.bluetooth_searching;
          statusText = 'Scanning…';
        } else if (state is BleConnecting) {
          bannerColor = const Color(0xFF6A1B9A); // purple
          iconData = Icons.bluetooth_searching;
          statusText = 'Connecting…';
        } else if (state is BleError) {
          bannerColor = const Color(0xFFC62828); // red
          iconData = Icons.bluetooth_disabled;
          statusText = 'BLE Error';
        } else {
          bannerColor = const Color(0xFF424242); // grey
          iconData = Icons.bluetooth;
          statusText = 'BLE Disconnected';
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bannerColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              // ── Animated icon ──────────────────────────────────────────
              isBusy
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Icon(iconData, color: Colors.white, size: 20),

              const SizedBox(width: 8),

              // ── Status text ────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (state is BleError)
                      Text(
                        state.message,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (isConnected)
                      Text(
                        deviceId,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),

              // ── Action button ──────────────────────────────────────────
              if (!isBusy)
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white24,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    if (isConnected) {
                      context.read<BleCubit>().disconnect();
                    } else {
                      context.read<BleCubit>().connect(deviceId);
                    }
                  },
                  child: Text(
                    isConnected ? 'Disconnect' : 'Connect',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}