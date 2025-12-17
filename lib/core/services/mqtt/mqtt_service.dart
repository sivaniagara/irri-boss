import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart' if (dart.library.html) 'package:mqtt_client/mqtt_browser_client.dart';

class MqttService {
  final String broker;
  final int port;
  final String clientIdentifier;
  final String userName;
  final String password;
  final String _subscribeTopic = "tweet";
  final String _publishTopic = "get-tweet-response";
  late MqttServerClient _client;
  bool _connected = false;

  MqttService({
    required this.broker,
    required this.port,
    required this.clientIdentifier,
    required this.userName,
    required this.password,
  });

  Future<void> connect() async {
    if (kDebugMode) {
      print('🔵 MqttService.connect: Broker=$broker, Port=$port, Client=$clientIdentifier');
      print('🔵 MqttService.connect: Username=${userName.isNotEmpty ? 'set' : 'empty'}, Password=${password.isNotEmpty ? 'set' : 'empty'}');
    }
    _client = MqttServerClient(broker, clientIdentifier);
    _client.port = port;
    _client.logging(on: false);
    _client.keepAlivePeriod = 30;
    _client.onDisconnected = _onDisconnected;
    _client.onConnected = _onConnected;
    _client.autoReconnect = true;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .authenticateAs(userName, password);
    _client.connectionMessage = connMess;
    if (kDebugMode) print('🔵 MqttService.connect: Connection message prepared');

    try {
      if (kDebugMode) print('🔵 MqttService.connect: Starting _client.connect()');
      await _client.connect();
      if (kDebugMode) print('🔵 MqttService.connect: _client.connect() succeeded');
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('🔵 MqttService.connect: _client.connect() FAILED: $e');
        print('🔵 MqttService.connect: Stack trace: $stackTrace');
      }
      _client.disconnect();
      rethrow; // Propagate to bloc
    }
  }

  void _onConnected() {
    _connected = true;
    if (kDebugMode) {
      print('MQTT connected');
    }
  }

  void _onDisconnected() {
    _connected = false;
    if (kDebugMode) {
      print('MQTT disconnected');
    }
  }

  bool get isConnected => _connected;

  void subscribe(String deviceId, {MqttQos qos = MqttQos.atMostOnce}) {
    if (_connected) {
      final topic = "$_subscribeTopic/$deviceId";
      _client.subscribe(topic, qos);
      if (kDebugMode) {
        print('Subscribed to: $topic');
      }
    }
  }

  // New: Unsubscribe method
  void unsubscribe(String deviceId, {MqttQos qos = MqttQos.atMostOnce}) {
    if (_connected) {
      final topic = "$_subscribeTopic/$deviceId";
      _client.unsubscribe(topic);
      if (kDebugMode) {
        print('Unsubscribed from: $topic');
      }
    }
  }

  void publish(String deviceId, String message, {MqttQos qos = MqttQos.atMostOnce}) {
    if (_connected) {
      final topic = "$_publishTopic/$deviceId";
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _client.publishMessage(topic, qos, builder.payload!);
      if (kDebugMode) {
        print('Published to $topic: $message');
      }
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>> get updates => _client.updates ?? Stream.empty();
}