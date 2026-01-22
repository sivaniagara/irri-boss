import 'package:equatable/equatable.dart';

import '../../domain/entities/fertilizer_entities.dart';



abstract class FertilizerState extends Equatable {
  const FertilizerState();

  @override
  List<Object?> get props => [];
}

/// Initial
class FertilizerInitial extends FertilizerState {}

/// Loading
class FertilizerLoading extends FertilizerState {}

/// Success
// class PowerGraphLoaded extends PowerGraphState {
//   final PowerGraphEntity data;
//
//   const PowerGraphLoaded(this.data);
//
//   @override
//   List<Object?> get props => [data];
// }

/// Error
class FertilizerError extends FertilizerState {
  final String message;

  const FertilizerError(this.message);

  @override
  List<Object?> get props => [message];
}

class FertilizerLoaded extends FertilizerState {
  final FertilizerEntity data;
  final String fromDate;
  final String toDate;


  FertilizerLoaded({
    required this.data,
    required this.fromDate,
    required this.toDate,

  });
}
