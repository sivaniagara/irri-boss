import 'package:equatable/equatable.dart';

abstract class ZoneCyclicEvent extends Equatable {
  const ZoneCyclicEvent();

  @override
  List<Object?> get props => [];
}

class FetchZoneCyclicEvent extends ZoneCyclicEvent {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const FetchZoneCyclicEvent({
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
class ToggleZoneCyclicViewEvent extends ZoneCyclicEvent {}
