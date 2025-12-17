import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/reportMenu/power_reports/domain/entities/power_entities.dart';

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
class PowerGraphLoaded extends PowerGraphState {
  final PowerGraphEntity data;

  const PowerGraphLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Error
class PowerGraphError extends PowerGraphState {
  final String message;

  const PowerGraphError(this.message);

  @override
  List<Object?> get props => [message];
}
