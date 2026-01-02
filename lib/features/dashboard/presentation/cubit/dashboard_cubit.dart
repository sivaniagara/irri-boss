import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/mqtt/mqtt_service.dart';
import '../../data/datasources/dashboard_remote_data_source.dart';
import '../../utils/dashboard_dispatcher.dart';

class DashboardCubit extends Cubit<bool> {
  final DashboardRemoteDataSource remote;
  final DashboardMessageDispatcher dispatcher;

  DashboardCubit({
    required this.remote,
    required this.dispatcher,
  }) : super(false);

  Future<void> motorOnOff({
    required int userId,
    required int subUserId,
    required int controllerId,
    required String deviceId,
    required bool isOn,
    required bool dualPump,
  }) async {
    emit(true);

    final sms = dualPump
        ? (isOn ? "MOTOR1ON" : "MTROF")
        : (isOn ? "MOTORON" : "MTROF");

    try {
      /// 🔹 API CALL
      await remote.motorOnOff(
        userId: userId,
        subUserId: subUserId,
        controllerId: controllerId,
        status: isOn ? "1" : "0",
        deviceId:deviceId,
        dualPump: dualPump,
      );
      sl.get<MqttService>().publish(
          deviceId,
          jsonEncode(sms)
      );
    } catch (e) {
      debugPrint("Motor switch error: $e");
    }

    emit(false);
  }
}

