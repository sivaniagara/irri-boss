import 'package:equatable/equatable.dart';

abstract class FlowGraphEvent extends Equatable {
  const FlowGraphEvent();

  @override
  List<Object?> get props => [];
}

class FetchFlowGraphEvent extends FlowGraphEvent {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const FetchFlowGraphEvent({
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
class ToggleFlowGraphViewEvent extends FlowGraphEvent {}
