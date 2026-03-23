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
    required bool m1on,
    required bool m2on,
    required bool mOff,
  }) async {
    emit(true);

    try {
      await remote.motorOnOff(
        userId: userId,
        subUserId: subUserId,
        controllerId: controllerId,
        status: isOn ? "1" : "0",
        deviceId: deviceId,
        dualPump: dualPump,
        m1on: m1on,
        m2on: m2on ,
        mOff: mOff,
      );

      final mqtt = sl.get<MqttService>();

      if (isOn && !dualPump) {
        mqtt.publish(deviceId, jsonEncode({"sentSms": "MTROF"}));
        await Future.delayed(const Duration(seconds: 5));
        final onSms =  "MTRON";
        mqtt.publish(deviceId, jsonEncode({"sentSms": onSms}));
      } else if (isOn && dualPump) {
        mqtt.publish(deviceId, jsonEncode({"sentSms": "MTROF"}));
        await Future.delayed(const Duration(seconds: 5));
        final onSms = m1on ? "MOTOR1ON" : "MOTOR2ON";
        mqtt.publish(deviceId, jsonEncode({"sentSms": onSms}));
      }
      else {
        mqtt.publish(deviceId, jsonEncode({"sentSms": "MTROF"}));
      }
    } catch (e) {
      debugPrint("Motor switch error: $e");
    }

    emit(false);
  }

}

