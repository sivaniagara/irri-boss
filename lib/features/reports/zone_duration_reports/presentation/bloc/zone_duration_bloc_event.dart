import 'package:equatable/equatable.dart';

abstract class ZoneDurationEvent extends Equatable {
  const ZoneDurationEvent();

  @override
  List<Object?> get props => [];
}

class FetchZoneDurationEvent extends ZoneDurationEvent {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const FetchZoneDurationEvent({
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
class ToggleZoneDurationViewEvent extends ZoneDurationEvent {}
