import '../../domain/entities/valve_flow_entity.dart';

abstract class ValveFlowState {}

class ValveFlowInitial extends ValveFlowState {}
class ValveFlowLoading extends ValveFlowState {}

class ValveFlowLoaded extends ValveFlowState {
  final String userId;
  final String controllerId;
  final String subUserId;
  final ValveFlowEntity entity;

  ValveFlowLoaded({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.entity,
  });

  ValveFlowLoaded copyWith({ValveFlowEntity? updatedEntity}) {
    return ValveFlowLoaded(
      userId: userId,
      controllerId: controllerId,
      subUserId: subUserId,
      entity: updatedEntity ?? entity,
    );
  }
}

class ValveFlowError extends ValveFlowState {
  final String message;
  ValveFlowError({required this.message});
}

class ValveFlowSuccess extends ValveFlowState {
  final String message;
  final ValveFlowEntity data;
  ValveFlowSuccess({required this.message, required this.data});
}
