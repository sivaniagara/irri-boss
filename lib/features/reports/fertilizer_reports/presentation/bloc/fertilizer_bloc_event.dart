import 'package:equatable/equatable.dart';

abstract class FertilizerEvent extends Equatable {
  const FertilizerEvent();

  @override
  List<Object?> get props => [];
}

class FetchFertilizerEvent extends FertilizerEvent {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  const FetchFertilizerEvent({
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
class ToggleFertilizerViewEvent extends FertilizerEvent {}
