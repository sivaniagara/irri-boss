import 'package:equatable/equatable.dart';

abstract class SerialSetEvent extends Equatable {
  const SerialSetEvent();
  @override
  List<Object?> get props => [];
}

class FetchSerialSetEvent extends SerialSetEvent {
  final String userId;
  final String controllerId;
  final String subUserId;
  final String deviceId;

  const FetchSerialSetEvent({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.deviceId,
  });

  @override
  List<Object?> get props => [userId, controllerId, subUserId, deviceId];
}

class UpdateLoraKeyEvent extends SerialSetEvent {
  final String value;
  const UpdateLoraKeyEvent(this.value);
  @override
  List<Object?> get props => [value];
}

class SendSerialSetMqttEvent extends SerialSetEvent {
  final String smsKey;
  final String? extraValue;
  final String successMessage;

  const SendSerialSetMqttEvent({
    required this.smsKey,
    this.extraValue,
    required this.successMessage,
  });

  @override
  List<Object?> get props => [smsKey, extraValue, successMessage];
}

class SaveSerialSetEvent extends SerialSetEvent {
  final String sentSms;
  const SaveSerialSetEvent({required this.sentSms});
  @override
  List<Object?> get props => [sentSms];
}
