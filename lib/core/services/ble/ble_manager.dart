import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_message_helper.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/log.dart';

import 'ble_service.dart';
import 'ble_service.dart';

/// Manages a single BLE device connection and feeds received data through
/// the EXISTING [MqttMessageHelper.processMessage] pipeline so all cubits
/// (Dashboard, FertilizerLive, PumpSettings, …) update without any changes.
///
/// Only one device is active at a time.
class BleManager {
  final BleService bleService;
  final MessageDispatcher dispatcher;

  StreamSubscription? _incomingSubscription;

  // Re-expose BLE state so UI can observe it.
  Stream<BleConnectionState> get stateStream => bleService.stateStream;
  BleConnectionState get state => bleService.state;

  BleManager({
    required this.bleService,
    required this.dispatcher,
  });

  /// Called when the dashboard selects a WLC controller.
  /// Scans + connects, then immediately requests live data.
  Future<void> connectAndSubscribe(String deviceId) async {
    // Cancel any previous incoming listener.
    await _incomingSubscription?.cancel();

    await bleService.connectToDevice(deviceId);

    // Listen to raw BLE strings and push through same MQTT pipeline.
    _incomingSubscription =
        bleService.incomingMessages.listen((rawMessage) {
          if (kDebugMode) kdebugmode('BLE → pipeline: $rawMessage');
          MqttMessageHelper.processMessage(rawMessage, dispatcher: dispatcher);
        });

    // Request live data exactly like MQTT does:
    //   sl<MqttManager>().publish(deviceId, jsonEncode(PublishMessageHelper.requestLive))
    await _requestLive();
  }

  Future<void> _requestLive() async {
    const liveRequest = '{"sentSms":"#live"}';
    await bleService.publish(liveRequest);
    if (kDebugMode) kdebugmode('BLE → sent #live request');
  }

  /// Publish any arbitrary payload to the connected BLE device.
  Future<void> publish(String payload) async {
    // Ensure it is valid JSON string, same as MqttManager does.
    String toSend;
    try {
      jsonDecode(payload); // throws if not JSON
      toSend = payload;
    } catch (_) {
      // Plain string command — wrap the same way MqttManager does for strings.
      toSend = payload;
    }
    await bleService.publish(toSend);
  }

  bool get isConnected => bleService.isConnected;
  String? get connectedDeviceId => bleService.connectedDeviceId;

  Future<void> disconnect() => bleService.disconnect();

  void dispose() {
    _incomingSubscription?.cancel();
    bleService.dispose();
  }
}