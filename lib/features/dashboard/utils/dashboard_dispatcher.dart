import 'dart:convert';

import '../../../core/di/injection.dart';
import '../../../core/services/mqtt/mqtt_manager.dart';
import '../../../core/services/mqtt/mqtt_message_helper.dart';
import '../../../core/services/mqtt/publish_messages.dart';
import '../domain/entities/livemessage_entity.dart';
import '../presentation/bloc/dashboard_bloc.dart';
import '../presentation/bloc/dashboard_event.dart';

class DashboardMessageDispatcher extends MessageDispatcher {
  final DashboardBloc dashboardBloc;

  DashboardMessageDispatcher({required this.dashboardBloc});

  @override
  void onLiveUpdate(String deviceId, LiveMessageEntity liveMessage) {
    dashboardBloc.add(UpdateLiveMessageEvent(deviceId, liveMessage));
  }


  @override
  void sendMotorCommand({
    required String deviceId,
    required String command,
  }) {
    sl<MqttManager>().publish(
      deviceId,
      jsonEncode(command),
    );
  }


}