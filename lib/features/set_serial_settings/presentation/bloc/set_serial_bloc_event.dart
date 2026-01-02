import 'package:equatable/equatable.dart';

abstract class SetSerialEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// LOAD SERIAL LIST
class LoadSerialEvent extends SetSerialEvent {
  final int userId;
  final int controllerId;

  LoadSerialEvent({required this.userId, required this.controllerId});

  @override
  List<Object?> get props => [userId, controllerId];
}

/// SEND SERIAL
class SendSerialEvent extends SetSerialEvent {
  final int userId;
  final int controllerId;
  final List<Map<String, dynamic>> sendList;
  final String sentSms;

  SendSerialEvent({
    required this.userId,
    required this.controllerId,
    required this.sendList,
    required this.sentSms,
  });

  @override
  List<Object?> get props => [userId, controllerId, sendList, sentSms];
}

/// RESET SERIAL
class ResetSerialEvent extends SetSerialEvent {
  final int userId;
  final int controllerId;
  final List<int> nodeIds;
  final String sentSms;

  ResetSerialEvent({
    required this.userId,
    required this.controllerId,
    required this.nodeIds,
    required this.sentSms,
  });

  @override
  List<Object?> get props => [userId, controllerId, nodeIds, sentSms];
}

/// VIEW SERIAL
class ViewSerialEvent extends SetSerialEvent {
  final int userId;
  final int controllerId;
  final String sentSms;

  ViewSerialEvent({
    required this.userId,
    required this.controllerId,
    required this.sentSms,
  });

  @override
  List<Object?> get props => [userId, controllerId, sentSms];
}
