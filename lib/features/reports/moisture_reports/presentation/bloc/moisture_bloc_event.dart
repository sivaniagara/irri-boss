import 'package:equatable/equatable.dart';

abstract class MoistureEvent extends Equatable {
  const MoistureEvent();

  @override
  List<Object?> get props => [];
}

class FetchMoistureEvent extends MoistureEvent {
  final int userId;
  final int subuserId;
  final int controllerId;

  const FetchMoistureEvent({
    required this.userId,
    required this.subuserId,
    required this.controllerId,
  });

  @override
  List<Object?> get props => [
    userId,
    subuserId,
    controllerId,
  ];
}