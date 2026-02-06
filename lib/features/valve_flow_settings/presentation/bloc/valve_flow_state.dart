import 'package:equatable/equatable.dart';
import '../../domain/entities/valve_flow_entity.dart';

abstract class ValveFlowState extends Equatable {
  const ValveFlowState();

  @override
  List<Object?> get props => [];
}

class ValveFlowInitial extends ValveFlowState {}

class ValveFlowLoading extends ValveFlowState {}

class ValveFlowLoaded extends ValveFlowState {
  final String userId;
  final String controllerId;
  final String subUserId;
  final String deviceId;
  final ValveFlowEntity entity;

  const ValveFlowLoaded({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.deviceId,
    required this.entity,
  });

  ValveFlowLoaded copyWith({
    ValveFlowEntity? updatedEntity,
  }) {
    return ValveFlowLoaded(
      userId: userId,
      controllerId: controllerId,
      subUserId: subUserId,
      deviceId: deviceId,
      entity: updatedEntity ?? entity,
    );
  }

  @override
  List<Object?> get props => [userId, controllerId, subUserId, deviceId, entity];
}

class ValveFlowSuccess extends ValveFlowState {
  final String message;
  final ValveFlowEntity data;

  const ValveFlowSuccess({required this.message, required this.data});

  @override
  List<Object?> get props => [message, data];
}

class ValveFlowError extends ValveFlowState {
  final String message;

  const ValveFlowError({required this.message});

  @override
  List<Object?> get props => [message];
}
