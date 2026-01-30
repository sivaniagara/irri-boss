class AlarmEntity {
  final int menuSettingId;
  final String menuItem;
  final String templateName;
  final String templateJson;
  final String smsFormat;
  final String deviceId;
  final AlarmDataEntity alarmData;

  AlarmEntity({
    required this.menuSettingId,
    required this.menuItem,
    required this.templateName,
    required this.templateJson,
    required this.smsFormat,
    required this.deviceId,
    required this.alarmData,
  });

  AlarmEntity copyWith({
    String? deviceId,
    AlarmDataEntity? alarmData,
  }) {
    return AlarmEntity(
      menuSettingId: menuSettingId,
      menuItem: menuItem,
      templateName: templateName,
      templateJson: templateJson,
      smsFormat: smsFormat,
      deviceId: deviceId ?? this.deviceId,
      alarmData: alarmData ?? this.alarmData,
    );
  }
}

class AlarmDataEntity {
  final String type;
  final String alarmType;
  final String alarmActive;
  final String irrigationStop;
  final String dosingStop;
  final String reset;
  final String hour;
  final String minutes;
  final String seconds;
  final String threshold;

  AlarmDataEntity({
    required this.type,
    required this.alarmType,
    required this.alarmActive,
    required this.irrigationStop,
    required this.dosingStop,
    required this.reset,
    required this.hour,
    required this.minutes,
    required this.seconds,
    required this.threshold,
  });

  AlarmDataEntity copyWith({
    String? type,
    String? alarmType,
    String? alarmActive,
    String? irrigationStop,
    String? dosingStop,
    String? reset,
    String? hour,
    String? minutes,
    String? seconds,
    String? threshold,
  }) {
    return AlarmDataEntity(
      type: type ?? this.type,
      alarmType: alarmType ?? this.alarmType,
      alarmActive: alarmActive ?? this.alarmActive,
      irrigationStop: irrigationStop ?? this.irrigationStop,
      dosingStop: dosingStop ?? this.dosingStop,
      reset: reset ?? this.reset,
      hour: hour ?? this.hour,
      minutes: minutes ?? this.minutes,
      seconds: seconds ?? this.seconds,
      threshold: threshold ?? this.threshold,
    );
  }
}
