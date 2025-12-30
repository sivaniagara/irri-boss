import 'package:equatable/equatable.dart';

import '../../domain/entities/power_entities.dart';

abstract class PowerGraphState extends Equatable {
  const PowerGraphState();

  @override
  List<Object?> get props => [];
}

/// Initial
class PowerGraphInitial extends PowerGraphState {}

/// Loading
class PowerGraphLoading extends PowerGraphState {}

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
class PowerGraphError extends PowerGraphState {
  final String message;

  const PowerGraphError(this.message);

  @override
  List<Object?> get props => [message];
}

class PowerGraphLoaded extends PowerGraphState {
  final PowerGraphEntity data;
  final String fromDate;
  final String toDate;

  PowerGraphLoaded({
    required this.data,
    required this.fromDate,
    required this.toDate,
  });
}
