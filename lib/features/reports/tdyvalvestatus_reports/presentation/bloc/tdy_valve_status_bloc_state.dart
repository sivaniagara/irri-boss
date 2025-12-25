import 'package:equatable/equatable.dart';
import '../../domain/entities/tdy_valve_status_entities.dart';

/// BASE STATE
abstract class TdyValveStatusState extends Equatable {
  const TdyValveStatusState();

  @override
  List<Object?> get props => [];
}

/// INITIAL
class TdyValveStatusInitial extends TdyValveStatusState {}

/// LOADING
class TdyValveStatusLoading extends TdyValveStatusState {}

/// ERROR
class TdyValveStatusError extends TdyValveStatusState {
  final String message;

  const TdyValveStatusError(this.message);

  @override
  List<Object?> get props => [message];
}

/// LOADED ✅ (MOST IMPORTANT)
class TdyValveStatusLoaded extends TdyValveStatusState {
  final TdyValveStatusEntity data;
  final String fromDate;
  final String program;

  const TdyValveStatusLoaded({
    required this.data,
    required this.fromDate,
    required this.program,
  });

  @override
  List<Object?> get props => [
    data,
    fromDate,
    program,
  ];
}
