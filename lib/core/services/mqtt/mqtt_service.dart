import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart' if (dart.library.html) 'package:mqtt_client/mqtt_browser_client.dart';

import '../../utils/common_toast.dart';

class MqttService {
  final String broker;
  final int port;
  final String clientIdentifier;
  final String userName;
  final String password;

  static const String _subscribeTopic = "tweet";
  static const String _publishTopic = "get-tweet-response";

  late MqttServerClient _client;

  bool _connected = false;

  final StreamController<bool> _connectionController =
  StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _connectionController.stream;
  bool get isConnected => _connected;

  MqttService({
    required this.broker,
    required this.port,
    required this.clientIdentifier,
    required this.userName,
    required this.password,
  });


  Future<void> connect() async {
    if (_connected) return;

    if (kDebugMode) {
      print('🔵 MQTT CONNECTING → $broker:$port ($clientIdentifier)');
    }

    _client = MqttServerClient(broker, clientIdentifier)
      ..port = port
      ..logging(on: false)
      ..keepAlivePeriod = 30
      ..autoReconnect = true
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected
      ..onAutoReconnect = _onAutoReconnect
      ..onAutoReconnected = _onAutoReconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .authenticateAs(userName, password);

    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ MQTT CONNECT FAILED: $e');
        print(stackTrace);
      }
      _client.disconnect();
      rethrow;
    }
  }

  void _onConnected() {
    _connected = true;
    _connectionController.add(true);

    if (kDebugMode) {
      print('✅ MQTT CONNECTED');
    }
  }

  void _onDisconnected() {
    _connected = false;
    _connectionController.add(false);

    if (kDebugMode) {
      print('🔴 MQTT DISCONNECTED');
    }
  }

  void _onAutoReconnect() {
    _connected = false;
    _connectionController.add(false);
    if (kDebugMode) {
      print('🔄 MQTT AUTO RECONNECTING...');
    }
  }

  void _onAutoReconnected() {
    _connected = true;
    _connectionController.add(true);
    if (kDebugMode) {
      print('✅ MQTT AUTO RECONNECTED');
    }
  }


  void subscribe(String deviceId,
      {MqttQos qos = MqttQos.atMostOnce}) {
    if (!_connected || _client.connectionStatus?.state != MqttConnectionState.connected) {
      if (kDebugMode) {
        print('⚠️ Subscribe failed – MQTT not connected');
      }
      return;
    }

    final topic = '$_subscribeTopic/$deviceId';
    _client.subscribe(topic, qos);

    if (kDebugMode) {
      print('📥 SUBSCRIBED → $topic');
    }
  }

  void unsubscribe(String deviceId) {
    if (!_connected || _client.connectionStatus?.state != MqttConnectionState.connected) return;

    final topic = '$_subscribeTopic/$deviceId';
    _client.unsubscribe(topic);

    if (kDebugMode) {
      print('📤 UNSUBSCRIBED → $topic');
    }
  }


  void publish(
      String deviceId,
      String message, {
        MqttQos qos = MqttQos.atMostOnce,
      }) {
    // Check both internal flag and actual client state to prevent "Current state is connecting" exception
    if (!_connected || _client.connectionStatus?.state != MqttConnectionState.connected) {
      if (kDebugMode) {
        print('⚠️ Publish skipped: MQTT state is ${_client.connectionStatus?.state}');
      }
      return;
    }

    final topic = '$_publishTopic/$deviceId';

    final builder = MqttClientPayloadBuilder()
      ..addString(message);

    try {
      _client.publishMessage(topic, qos, builder.payload!);
      if (kDebugMode) {
        print('📤 PUBLISHED → $topic | $message');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Publish failed: $e');
      }
    }
  }


  Stream<List<MqttReceivedMessage<MqttMessage>>> get updates =>
      _client.updates ?? Stream.empty();


  void dispose() {
    _connectionController.close();
    _client.disconnect();
  }
}
