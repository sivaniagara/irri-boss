import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';

import 'mqtt_message_helper.dart';
import 'mqtt_service.dart';

class MqttManager {
  final MqttService mqttService;
  final MessageDispatcher dispatcher;

  StreamSubscription? _subscription;
  String? _currentDeviceId;
  bool _started = false;

  MqttManager({
    required this.mqttService,
    required this.dispatcher,
  }) {
    _start();
  }

  void _start() async {
    if (_started) return;
    _started = true;

    await mqttService.connect();

    _subscription = mqttService.updates.listen((messages) {
      for (final msg in messages) {
        final payload = msg.payload as MqttPublishMessage;
        final message =
        MqttPublishPayload.bytesToStringAsString(
          payload.payload.message,
        );

        MqttMessageHelper.processMessage(
          message,
          dispatcher: dispatcher,
        );
      }
    });
  }

  void subscribe(String deviceId) {
    if (_currentDeviceId == deviceId) return;

    if (_currentDeviceId != null) {
      mqttService.unsubscribe(_currentDeviceId!);
    }

    mqttService.subscribe(deviceId);
    _currentDeviceId = deviceId;
  }

  void publish(String deviceId, String payload) {
    mqttService.publish(deviceId, payload);
  }

  void dispose() {
    _subscription?.cancel();
  }
}
