import 'dart:async';
import 'dart:convert'; // For jsonEncode if needed
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../../core/di/injection.dart';
import '../../../core/services/mqtt_service.dart';
import '../../../core/services/selected_controller_persistence.dart';
import '../utils/mqtt_message_helper.dart';
import 'mqtt_event.dart';
import 'mqtt_state.dart';

class MqttBloc extends Bloc<MqttEvent, MqttState> {
  final MqttService mqttService;
  StreamSubscription? _subscription;
  BuildContext? _processingContext;
  Timer? _retryTimer;
  int _retryAttempts = 0;
  static const int maxRetries = 5;
  static const Duration retryDelay = Duration(seconds: 5);
  String? _currentDeviceId;
  bool get isConnected => mqttService.isConnected;
  final persistence = sl.get<SelectedControllerPersistence>();

  MqttBloc({required this.mqttService}) : super(MqttInitial()) {
    on<ConnectMqttEvent>(_onConnect);
    on<SubscribeMqttEvent>(_onSubscribe);
    on<PublishMqttEvent>(_onPublish);
    on<ReceivedMqttMessageEvent>(_onReceivedMessage);
    add(ConnectMqttEvent());
  }

  void setProcessingContext(BuildContext context) {
    _processingContext = context;
  }

  Future<void> _onConnect(ConnectMqttEvent event, Emitter<MqttState> emit) async {
    if (kDebugMode) print('🔵 MqttBloc._onConnect: Starting connection attempt $_retryAttempts');
    emit(MqttLoading());
    try {
      if (kDebugMode) print('🔵 MqttBloc._onConnect: Calling mqttService.connect()');
      await mqttService.connect();
      _retryAttempts = 0;
      if (kDebugMode) print('🔵 MqttBloc._onConnect: Connected successfully');
      emit(MqttConnected());

      _subscription = mqttService.updates.listen((messages) {
        if (kDebugMode) print('🔵 MqttBloc._onConnect: Listener set up');
        for (var message in messages) {
          final payload = message.payload as MqttPublishMessage;
          final msgString = MqttPublishPayload.bytesToStringAsString(payload.payload.message);
          add(ReceivedMqttMessageEvent(topic: message.topic, message: msgString));
        }
      });
      if (kDebugMode) print('🔵 MqttBloc._onConnect: State now MqttConnected');
    } catch (e, stackTrace) {
      _retryAttempts++;
      final errorMsg = 'MQTT Connect failed (attempt $_retryAttempts/$maxRetries): $e';
      if (kDebugMode) {
        print('🔵 MqttBloc._onConnect: ERROR - $errorMsg');
        print('🔵 MqttBloc._onConnect: Stack trace: $stackTrace');
      }
      emit(MqttError(errorMsg));

      final shouldRetry = _retryAttempts < maxRetries &&
          (e.toString().contains('notAuthorized') ||
              e.toString().contains('NoConnectionException') ||
              e.toString().contains('SocketException') ||
              e.toString().contains('TimeoutException'));
      if (shouldRetry) {
        if (kDebugMode) print('🔵 MqttBloc._onConnect: Scheduling retry in ${retryDelay.inSeconds}s');
        _retryTimer?.cancel();
        _retryTimer = Timer(retryDelay, () => add(ConnectMqttEvent()));
      } else if (_retryAttempts >= maxRetries) {
        if (kDebugMode) {
          print('🔵 MqttBloc._onConnect: Max retries exceeded; manual retry needed');
        }
      } else {
        if (kDebugMode) print('🔵 MqttBloc._onConnect: No retry (error type mismatch: ${e.toString()})');
      }
    }
  }

  void _onSubscribe(SubscribeMqttEvent event, Emitter<MqttState> emit) {
  if (kDebugMode) {
    print("_onSubscribe called for deviceId: ${persistence.deviceId}");
    print("_onSubscribe current state: ${state.runtimeType}");
  }
  if (mqttService.isConnected) {
    if (_currentDeviceId == persistence.deviceId) {
      if (kDebugMode) print('Already subscribed to ${persistence.deviceId} - skipping');
      return;
    }
    if (_currentDeviceId != null) {
      if (kDebugMode) print('Unsubscribing from old topic: tweet/$_currentDeviceId');
      mqttService.unsubscribe(_currentDeviceId!);
    }

    mqttService.subscribe(persistence.deviceId!);
    _currentDeviceId = persistence.deviceId;

    if (kDebugMode) print('Subscribed to new topic: tweet/${persistence.deviceId}');

    final publishMessage = jsonEncode(PublishMessageHelper.requestLive);
    mqttService.publish(persistence.deviceId!, publishMessage);
    // mqttService.publish(persistence.deviceId, publishMessage);
    if (kDebugMode) print('Published message after subscribe: $publishMessage');
  } else {
    if (kDebugMode) print('Skipped subscribe; service not connected');
    if (_retryAttempts < maxRetries) {
      add(ConnectMqttEvent());
    }
  }
}

  void _onPublish(PublishMqttEvent event, Emitter<MqttState> emit) {
    if (mqttService.isConnected) {
      mqttService.publish(persistence.deviceId!, event.message);
    } else {
      if (kDebugMode) {
        print('🔵 MqttBloc._onPublish: Skipped; service not connected');
      }
      if (_retryAttempts < maxRetries) {
        add(ConnectMqttEvent());
      }
    }
  }

  void _onReceivedMessage(ReceivedMqttMessageEvent event, Emitter<MqttState> emit) {
    if (kDebugMode) {
      print("Subscribed topic :: ${event.topic}");
      print("Received message :: ${event.message}");
    }

    final dispatcher = sl<MessageDispatcher>();
    MqttMessageHelper.processMessage(
      event.message,
      dispatcher: dispatcher,
      context: _processingContext,
    );

    // FIXED: Always accumulate, but initialize if needed (won't overwrite connected)
    final currentState = state is MqttMessagesState ? state as MqttMessagesState : MqttMessagesState();
    final newMessages = Map<String, List<MqttMessageRecord>>.from(currentState.messagesByTopic);
    final record = MqttMessageRecord(topic: event.topic, message: event.message);

    if (!newMessages.containsKey(event.topic)) {
      newMessages[event.topic] = [];
    }
    newMessages[event.topic]!.add(record);

    emit(currentState.copyWith(messagesByTopic: newMessages));
  }

  void clearMessagesForTopic(String topic) {
    if (state is MqttMessagesState) {
      final currentState = state as MqttMessagesState;
      final newMessages = Map<String, List<MqttMessageRecord>>.from(currentState.messagesByTopic);
      newMessages.remove(topic);
      emit(currentState.copyWith(messagesByTopic: newMessages));
    }
  }

  @override
  Future<void> close() {
    // Unsubscribe from current topic on close
    if (_currentDeviceId != null && state is MqttConnected) {
      mqttService.unsubscribe(_currentDeviceId!);
    }
    _processingContext = null;
    _retryTimer?.cancel();
    _subscription?.cancel();
    return super.close();
  }
}