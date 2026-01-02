import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/flow_graph_reports/domain/entities/flow_graph_entities.dart';

/// BASE STATE
abstract class FlowGraphState extends Equatable {
  const FlowGraphState();

  @override
  List<Object?> get props => [];
}

/// INITIAL
class FlowGraphInitial extends FlowGraphState {}

/// LOADING
class FlowGraphLoading extends FlowGraphState {}

/// ERROR
class FlowGraphError extends FlowGraphState {
  final String message;

  const FlowGraphError(this.message);

  @override
  List<Object?> get props => [message];
}

/// LOADED ✅ (MOST IMPORTANT)
class FlowGraphLoaded extends FlowGraphState {
  final FlowGraphEntities data;
  final String fromDate;
  final String toDate;

  const FlowGraphLoaded({
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
