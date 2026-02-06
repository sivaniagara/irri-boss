import 'dart:convert';
import '../../domain/entities/alarm_entity.dart';

class AlarmModel extends AlarmEntity {
  AlarmModel({
    required super.menuSettingId,
    required super.menuItem,
    required super.templateName,
    required super.templateJson,
    required super.smsFormat,
    required super.deviceId,
    required super.alarmData,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    var rawSendData = json['sendData'];
    Map<String, dynamic> sendDataMap = {};
    if (rawSendData is String) {
      try {
        sendDataMap = jsonDecode(rawSendData);
      } catch (_) {}
    } else if (rawSendData is Map) {
      sendDataMap = Map<String, dynamic>.from(rawSendData);
    }

    return AlarmModel(
      menuSettingId: json['menuSettingId'] ?? 0,
      menuItem: json['menuItem'] ?? '',
      templateName: json['templateName'] ?? '',
      templateJson: json['templateJson']?.toString() ?? '',
      smsFormat: json['smsFormat']?.toString() ?? '',
      deviceId: '', // Populated by Bloc
      alarmData: AlarmDataModel.fromJson(sendDataMap),
    );
  }
}

class AlarmDataModel extends AlarmDataEntity {
  AlarmDataModel({
    required super.type,
    required super.alarmType,
    required super.alarmActive,
    required super.irrigationStop,
    required super.dosingStop,
    required super.reset,
    required super.hour,
    required super.minutes,
    required super.seconds,
    required super.threshold,
  });

  factory AlarmDataModel.fromJson(Map<String, dynamic> json) {
    return AlarmDataModel(
      type: json['type']?.toString() ?? '',
      alarmType: json['alarmType']?.toString() ?? '0',
      alarmActive: json['alarmActive']?.toString() ?? '0',
      irrigationStop: json['irrigationStop']?.toString() ?? '0',
      dosingStop: json['dosingStop']?.toString() ?? '0',
      reset: json['reset']?.toString() ?? '0',
      hour: json['hour']?.toString() ?? '00',
      minutes: json['minutes']?.toString() ?? '00',
      seconds: json['seconds']?.toString() ?? '00',
      threshold: json['threshold']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'alarmType': alarmType,
      'alarmActive': alarmActive,
      'irrigationStop': irrigationStop,
      'dosingStop': dosingStop,
      'reset': reset,
      'hour': hour,
      'minutes': minutes,
      'seconds': seconds,
      'threshold': threshold,
    };
  }
}
