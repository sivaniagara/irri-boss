import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_message_helper.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/log.dart';

import 'ble_service.dart';

/// Buffers raw BLE string chunks and releases a complete JSON payload
/// only once the accumulated data forms a balanced JSON object.
///
/// Needed because BLE (unlike MQTT) may deliver one logical payload
/// split across two or more notify/write packets due to MTU limits.
/// The payload here is a FLAT (non-nested) JSON object, so simple
/// brace-balance tracking (ignoring braces inside quoted strings) is
/// enough to know when the object is complete.
class _BleJsonAssembler {
  final StringBuffer _buffer = StringBuffer();

  /// Feed a raw chunk. Returns the complete JSON string once assembled,
  /// or null if more packets are still expected.
  String? feed(String chunk) {
    _buffer.write(chunk);
    final String data = _buffer.toString();

    if (_isCompleteJson(data)) {
      _buffer.clear();
      return data.trim();
    }
    return null;
  }

  void reset() => _buffer.clear();

  bool _isCompleteJson(String data) {
    int braceCount = 0;
    bool inString = false;
    bool escape = false;
    bool sawOpenBrace = false;

    for (int i = 0; i < data.length; i++) {
      final String ch = data[i];

      if (escape) {
        escape = false;
        continue;
      }
      if (ch == '\\') {
        escape = true;
        continue;
      }
      if (ch == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;

      if (ch == '{') {
        braceCount++;
        sawOpenBrace = true;
      } else if (ch == '}') {
        braceCount--;
      }
    }

    // Complete only once every opened brace has been closed, and we
    // actually saw at least one object start (avoids firing on empty
    // or garbage chunks).
    return sawOpenBrace && braceCount == 0;
  }
}

/// Manages a single BLE device connection and feeds received data through
/// the EXISTING [MqttMessageHelper.processMessage] pipeline so all cubits
/// (Dashboard, FertilizerLive, PumpSettings, …) update without any changes.
///
/// Only one device is active at a time.
class BleManager {
  final BleService bleService;
  final MessageDispatcher dispatcher;

  StreamSubscription? _incomingSubscription;
  final _BleJsonAssembler _assembler = _BleJsonAssembler();

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
    // Cancel any previous incoming listener and clear any partial data
    // left over from a prior connection.
    await _incomingSubscription?.cancel();
    _assembler.reset();

    await bleService.connectToDevice(deviceId);

    // Listen to raw BLE strings, reassemble split packets into a single
    // complete JSON payload, and push through the same MQTT pipeline.
    _incomingSubscription = bleService.incomingMessages.listen((rawChunk) {
      if (kDebugMode) kdebugmode('BLE ← raw chunk: $rawChunk');

      final String? completeJson = _assembler.feed(rawChunk);
      if (completeJson == null) {
        // Still waiting for the rest of the payload.
        if (kDebugMode) kdebugmode('BLE ← partial packet, buffering...');
        return;
      }

      if (kDebugMode) kdebugmode('BLE → pipeline (assembled): $completeJson');
      MqttMessageHelper.processMessage(completeJson, dispatcher: dispatcher);
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

  Future<void> disconnect() {
    _assembler.reset();
    return bleService.disconnect();
  }

  void dispose() {
    _incomingSubscription?.cancel();
    _assembler.reset();
    bleService.dispose();
  }
}