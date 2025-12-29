import 'package:equatable/equatable.dart';
import '../../domain/entities/flow_graph_entities.dart';

abstract class FlowGraphState extends Equatable {
  const FlowGraphState();

  @override
  List<Object?> get props => [];
}

/// Initial
class FlowGraphInitial extends FlowGraphState {}

/// Loading
class FlowGraphLoading extends FlowGraphState {}

/// Success
class FlowGraphLoaded extends FlowGraphState {
  final FlowGraphEntities data;

  const FlowGraphLoaded(this.data);

  @override
  List<Object?> get props => [data];
}

/// Error
class FlowGraphError extends FlowGraphState {
  final String message;

  const FlowGraphError(this.message);

  @override
  List<Object?> get props => [message];
}
