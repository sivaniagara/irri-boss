import 'package:equatable/equatable.dart';

abstract class AlarmEvent extends Equatable {
  const AlarmEvent();
  @override
  List<Object?> get props => [];
}

class FetchAlarmDataEvent extends AlarmEvent {
  final String userId;
  final String controllerId;
  final String deviceId;
  final String subUserId;

  const FetchAlarmDataEvent({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.subUserId,
  });

  @override
  List<Object?> get props => [userId, controllerId, deviceId, subUserId];
}

class UpdateAlarmFieldEvent extends AlarmEvent {
  final String? alarmType;
  final String? alarmActive;
  final String? irrigationStop;
  final String? dosingStop;
  final String? reset;
  final String? hour;
  final String? minutes;
  final String? seconds;
  final String? threshold;

  const UpdateAlarmFieldEvent({
    this.alarmType,
    this.alarmActive,
    this.irrigationStop,
    this.dosingStop,
    this.reset,
    this.hour,
    this.minutes,
    this.seconds,
    this.threshold,
  });

  @override
  List<Object?> get props => [
    alarmType,
    alarmActive,
    irrigationStop,
    dosingStop,
    reset,
    hour,
    minutes,
    seconds,
    threshold,
  ];
}

class SaveAlarmSettingsEvent extends AlarmEvent {
  const SaveAlarmSettingsEvent();
}

class CancelAlarmEditEvent extends AlarmEvent {
  const CancelAlarmEditEvent();
}
