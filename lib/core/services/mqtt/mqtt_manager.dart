import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'mqtt_message_helper.dart';
import 'mqtt_service.dart';

class MqttManager {
  final MqttService mqttService;
  final MessageDispatcher dispatcher;

  StreamSubscription? _subscription;
  String? _currentDeviceId;
  bool _started = false;

  final StreamController<String> _messageController = StreamController<String>.broadcast();
  Stream<String> get messages => _messageController.stream;

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
        debugPrint("messages---->$messages");
        _messageController.add(message);
        MqttMessageHelper.processMessage(
          message,
          dispatcher: dispatcher,
        );
      }
    });
  }

  void subscribe(String deviceId, {bool force = false}) {
    print("call subscribe");

    if (_currentDeviceId == deviceId && !force) return;

    if (_currentDeviceId != null && _currentDeviceId != deviceId) {
      mqttService.unsubscribe(_currentDeviceId!);
    }

    mqttService.subscribe(deviceId);
    _currentDeviceId = deviceId;
  }

  void publish(String deviceId, dynamic payload) {
    _currentDeviceId != deviceId;
    {
      subscribe(deviceId, force: true);
    }
    if(payload is String){
      mqttService.publish(deviceId, payload);
    }else{
      mqttService.publish(deviceId, jsonEncode(payload));
    }
  }

  void dispose() {
    _subscription?.cancel();
    _messageController.close();
  }
}
