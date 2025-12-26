import 'package:equatable/equatable.dart';
import '../../domain/entities/zone_cyclic_entities.dart';

/// BASE STATE
abstract class ZoneCyclicState extends Equatable {
  const ZoneCyclicState();

  @override
  List<Object?> get props => [];
}

/// INITIAL
class ZoneCyclicInitial extends ZoneCyclicState {}

/// LOADING
class ZoneCyclicLoading extends ZoneCyclicState {}

/// ERROR
class ZoneCyclicError extends ZoneCyclicState {
  final String message;

  const ZoneCyclicError(this.message);

  @override
  List<Object?> get props => [message];
}

/// LOADED ✅ (MOST IMPORTANT)
class ZoneCyclicLoaded extends ZoneCyclicState {
  final ZoneCyclicEntity data;
  final String fromDate;
  final String toDate;

  const ZoneCyclicLoaded({
    required this.data,
    required this.fromDate,
    required this.toDate,
  });

  @override
  List<Object?> get props => [
    data,
    fromDate,
    toDate,
  ];
}
