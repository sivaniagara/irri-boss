import 'dart:convert';

import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/dashboard_page_cubit.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/mqtt/mqtt_manager.dart';
import '../../../core/services/mqtt/mqtt_message_helper.dart';
import '../domain/entities/livemessage_entity.dart';

class DashboardMessageDispatcher extends MessageDispatcher {
  final DashboardPageCubit dashboardBloc;

  DashboardMessageDispatcher({required this.dashboardBloc});

  @override
  void onLiveUpdate(String deviceId, LiveMessageEntity liveMessage) {
    dashboardBloc.updateLiveMessage(deviceId, liveMessage);
    // dashboardBloc.add(UpdateLiveMessageEvent(deviceId, liveMessage));
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