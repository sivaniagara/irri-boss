import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:niagara_smart_drip_irrigation/core/utils/log.dart';

import 'ble_manager.dart';
import 'ble_service.dart';

// ── States ────────────────────────────────────────────────────────────────────

abstract class BleState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BleIdle extends BleState {}

class BleScanning extends BleState {}

class BleConnecting extends BleState {}

class BleConnected extends BleState {
  final String deviceId;
  BleConnected(this.deviceId);

  @override
  List<Object?> get props => [deviceId];
}

class BleDisconnected extends BleState {}

class BleError extends BleState {
  final String message;
  BleError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────────

/// Cubit consumed by [Dashboard20] to show BLE status for WLC models.
/// Wraps [BleManager] and converts [BleConnectionState] into bloc states.
class BleCubit extends Cubit<BleState> {
  final BleManager bleManager;
  StreamSubscription? _stateSub;

  BleCubit({required this.bleManager}) : super(BleIdle()) {
    _stateSub = bleManager.stateStream.listen(_onServiceState);
  }

  void _onServiceState(BleConnectionState s) {
    if (isClosed) return;
    switch (s) {
      case BleConnectionState.scanning:
        emit(BleScanning());
        break;
      case BleConnectionState.connecting:
        emit(BleConnecting());
        break;
      case BleConnectionState.connected:
        emit(BleConnected(bleManager.connectedDeviceId ?? ''));
        break;
      case BleConnectionState.disconnected:
        emit(BleDisconnected());
        break;
      case BleConnectionState.error:
        emit(BleError('BLE connection failed'));
        break;
    }
  }

  /// Triggers scan + connect + live request for [deviceId].
  Future<void> connect(String deviceId) async {
    emit(BleScanning());
    try {
      await bleManager.connectAndSubscribe(deviceId);
      // State emitted by _onServiceState listener
    } catch (e) {
      if (!isClosed) emit(BleError(e.toString()));
    }
  }

  Future<void> disconnect() async {
    await bleManager.disconnect();
  }

  @override
  Future<void> close() {
    _stateSub?.cancel();
    return super.close();
  }
}