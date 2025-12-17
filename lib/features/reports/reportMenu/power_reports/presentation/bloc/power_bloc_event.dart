import 'package:equatable/equatable.dart';

abstract class PowerGraphEvent extends Equatable {
  const PowerGraphEvent();

  @override
  List<Object?> get props => [];
}

class FetchPowerGraphEvent extends PowerGraphEvent {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const FetchPowerGraphEvent({
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
