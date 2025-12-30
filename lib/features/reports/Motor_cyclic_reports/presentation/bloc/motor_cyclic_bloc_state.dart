import 'package:equatable/equatable.dart';

import '../../domain/entities/motor_cyclic_entities.dart';
import 'motor_cyclic_mode.dart';


abstract class MotorCyclicState extends Equatable {
  const MotorCyclicState();

  @override
  List<Object?> get props => [];
}

/// Initial
class MotorCyclicInitial extends MotorCyclicState {}

/// Loading
class MotorCyclicLoading extends MotorCyclicState {}


/// Error
class MotorCyclicError extends MotorCyclicState {
  final String message;

  const MotorCyclicError(this.message);

  @override
  List<Object?> get props => [message];
}

class MotorCyclicLoaded extends MotorCyclicState {
  final MotoCyclicEntity data;
  final String fromDate;
  final String toDate;


  MotorCyclicLoaded({
    required this.data,
    required this.fromDate,
    required this.toDate,

  });
}
