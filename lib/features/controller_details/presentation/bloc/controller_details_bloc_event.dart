import 'package:equatable/equatable.dart';

abstract class ControllerDetailsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetControllerDetailsEvent extends ControllerDetailsEvent {
  final int userId;
  final int controllerId;

  GetControllerDetailsEvent({
    required this.userId,
    required this.controllerId,
  });

  @override
  List<Object?> get props => [userId, controllerId];
}
class ToggleSwitchEvent extends ControllerDetailsEvent {
  // final int controllerId;
  final String switchName;  // Example: "motor", "pump", "valve"
  final bool isOn;

  ToggleSwitchEvent({
    // required this.controllerId,
    required this.switchName,
    required this.isOn,
  });

  @override
  List<Object?> get props => [ switchName, isOn];
}

class UpdateControllerEvent extends ControllerDetailsEvent {
  final String userId;
  final int controllerId;
  final String countryCode;
  final String simNumber;
  final String deviceName;
  final int groupId;
  final String operationMode;
  final String gprsMode;
  final String appSmsMode;
  final String sentSms;
  final String editType;

  UpdateControllerEvent({
    required this.userId,
    required this.controllerId,
    required this.countryCode,
    required this.simNumber,
    required this.deviceName,
    required this.groupId,
    required this.operationMode,
    required this.gprsMode,
    required this.appSmsMode,
    required this.sentSms,
    required this.editType,
  });

  @override
  List<Object?> get props => [
    userId,
    controllerId,
    countryCode,
    simNumber,
    deviceName,
    groupId,
    operationMode,
    gprsMode,
    appSmsMode,
    sentSms,
    editType,
  ];
}
