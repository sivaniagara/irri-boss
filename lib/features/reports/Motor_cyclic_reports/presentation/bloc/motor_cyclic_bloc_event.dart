import 'package:equatable/equatable.dart';

abstract class MotorCyclicEvent extends Equatable {
  const MotorCyclicEvent();

  @override
  List<Object?> get props => [];
}

class FetchMotorCyclicEvent extends MotorCyclicEvent {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const FetchMotorCyclicEvent({
    required this.userId,
    required this.subuserId,
    required this.controllerId,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [
    userId,
    subuserId,
    controllerId,
    fromDate,
    toDate,
  ];
}
class ToggleMotorCyclicViewEvent extends MotorCyclicEvent {}
