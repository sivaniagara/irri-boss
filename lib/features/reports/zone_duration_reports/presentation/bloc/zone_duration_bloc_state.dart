import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zone_duration_reports/domain/entities/zone_duration_entities.dart';



abstract class ZoneDurationState extends Equatable {
  const ZoneDurationState();

  @override
  List<Object?> get props => [];
}

/// Initial
class ZoneDurationInitial extends ZoneDurationState {}

/// Loading
class ZoneDurationLoading extends ZoneDurationState {}

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
class ZoneDurationError extends ZoneDurationState {
  final String message;

  const ZoneDurationError(this.message);

  @override
  List<Object?> get props => [message];
}

class ZoneDurationLoaded extends ZoneDurationState {
  final ZoneDurationEntity data;
  final String fromDate;
  final String toDate;


  ZoneDurationLoaded({
    required this.data,
    required this.fromDate,
    required this.toDate,

  });
}
