import 'package:equatable/equatable.dart';

abstract class StandaloneEvent extends Equatable {
  const StandaloneEvent();

  @override
  List<Object?> get props => [];
}

class FetchStandaloneEvent extends StandaloneEvent {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const FetchStandaloneEvent({
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
class ToggleStandaloneViewEvent extends StandaloneEvent {}
