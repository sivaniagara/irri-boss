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
  void onLiveUpdate(String deviceId, LiveMessageEntity liveMessage, {String? date, String? fullMsg, String? msgDesc, String? time}) {
    dashboardBloc.updateLiveMessage(deviceId, liveMessage, date: date, time: time, fullMsg: fullMsg, msgDesc: msgDesc);
  }

  @override
  void onServerTimeUpdate(String deviceId, {String? date, String? time}) {
    dashboardBloc.updateServerTime(deviceId, date: date, time: time);
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
