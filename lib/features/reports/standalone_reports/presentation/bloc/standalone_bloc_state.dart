import 'package:equatable/equatable.dart';

import '../../domain/entities/standalone_entities.dart';

 


abstract class StandaloneState extends Equatable {
  const StandaloneState();

  @override
  List<Object?> get props => [];
}

/// Initial
class StandaloneInitial extends StandaloneState {}

/// Loading
class StandaloneLoading extends StandaloneState {}

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
class StandaloneError extends StandaloneState {
  final String message;

  const StandaloneError(this.message);

  @override
  List<Object?> get props => [message];
}

class StandaloneLoaded extends StandaloneState {
  final StandaloneEntity data;
  final String fromDate;
  final String toDate;


  StandaloneLoaded({
    required this.data,
    required this.fromDate,
    required this.toDate,

  });
}
