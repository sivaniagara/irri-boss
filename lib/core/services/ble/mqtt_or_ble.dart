import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_manager.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/log.dart';

import 'ble_manager.dart';

/// Drop-in router that sits between every feature cubit and the transport layer.
///
/// Rule:
///   • If the target [deviceId] has an active BLE connection → send via BLE.
///   • Otherwise → fall through to MQTT (existing [MqttManager]).
///
/// This is the ONLY place that knows about BLE vs MQTT.
/// Every other page/cubit keeps calling publish() exactly as before.
///
/// Usage in DI (injection.dart):
///   sl.registerLazySingleton(() => WlcBleRouter(
///     mqttManager: sl<MqttManager>(),
///     bleManager: sl<BleManager>(),
///   ));
///
/// Then replace sl<MqttManager>().publish(...) calls in cubits with
///   sl<WlcBleRouter>().publish(deviceId, payload)
///
/// OR, for zero touch on existing files, register WlcBleRouter as the
/// MqttManager in sl — both expose `publish(deviceId, payload)` with the
/// same signature, so you can do a single DI swap.
class MqttOrBle {
  final MqttManager mqttManager;
  final BleManager bleManager;

  MqttOrBle({
    required this.mqttManager,
    required this.bleManager,
  });

  /// Publishes [payload] to [deviceId] via BLE if connected, else via MQTT.
  void publish(String deviceId, dynamic payload) {
    print("payload ::: ${payload}");
    if (bleManager.isConnected &&
        bleManager.connectedDeviceId == deviceId) {
      // BLE path
      final String message =
      payload is String ? payload : jsonEncode(payload);
      if (kDebugMode) {
        kdebugmode('WlcBleRouter → BLE: $deviceId | $message');
      }
      bleManager.publish(message);
    } else {
      // MQTT path — unchanged
      if (kDebugMode) {
        kdebugmode('WlcBleRouter → MQTT: $deviceId');
      }
      mqttManager.publish(deviceId, payload);
    }
  }

  /// Subscribe for incoming data. For BLE devices this is a no-op because
  /// [BleManager.connectAndSubscribe] already sets up the listener.
  void subscribe(String deviceId, {bool force = false}) {
    if (bleManager.isConnected && bleManager.connectedDeviceId == deviceId) {
      return; // BLE handles subscription internally
    }
    mqttManager.subscribe(deviceId, force: force);
  }
}