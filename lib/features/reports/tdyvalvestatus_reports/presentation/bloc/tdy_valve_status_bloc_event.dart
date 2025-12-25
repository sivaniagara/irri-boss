import 'package:equatable/equatable.dart';

abstract class TdyValveStatusEvent extends Equatable {
  const TdyValveStatusEvent();

  @override
  List<Object?> get props => [];
}

class FetchTdyValveStatusEvent extends TdyValveStatusEvent {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String program;

  const FetchTdyValveStatusEvent({
    required this.userId,
    required this.subuserId,
    required this.controllerId,
    required this.fromDate,
    required this.program,
  });

  @override
  List<Object?> get props => [
    userId,
    subuserId,
    controllerId,
    fromDate,
    program,
  ];
}
class ToggleTdyValveStatusViewEvent extends TdyValveStatusEvent {}
