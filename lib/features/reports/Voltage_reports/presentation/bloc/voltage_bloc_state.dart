import 'package:equatable/equatable.dart';
import '../../domain/entities/voltage_entities.dart';

abstract class VoltageGraphState extends Equatable {
  const VoltageGraphState();

  @override
  List<Object?> get props => [];
}

/// Initial
class VoltageGraphInitial extends VoltageGraphState {}

/// Loading
class VoltageGraphLoading extends VoltageGraphState {}

/// Success
class VoltageGraphLoaded extends VoltageGraphState {
  final VoltageGraphEntities data;

  const VoltageGraphLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Error
class VoltageGraphError extends VoltageGraphState {
  final String message;

  const VoltageGraphError(this.message);

  @override
  List<Object?> get props => [message];
}
