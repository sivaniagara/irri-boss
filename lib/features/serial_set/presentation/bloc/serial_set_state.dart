import 'package:equatable/equatable.dart';
import '../../domain/entities/serial_set_entity.dart';

abstract class SerialSetState extends Equatable {
  const SerialSetState();
  @override
  List<Object?> get props => [];
}

class SerialSetInitial extends SerialSetState {}

class SerialSetLoading extends SerialSetState {}

class SerialSetLoaded extends SerialSetState {
  final String userId;
  final String controllerId;
  final String subUserId;
  final String deviceId;
  final SerialSetEntity entity;

  const SerialSetLoaded({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.deviceId,
    required this.entity,
  });

  SerialSetLoaded copyWith({
    SerialSetEntity? updatedEntity,
  }) {
    return SerialSetLoaded(
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

class SerialSetActionSuccess extends SerialSetState {
  final String message;
  final SerialSetEntity entity;

  const SerialSetActionSuccess({required this.message, required this.entity});

  @override
  List<Object?> get props => [message, entity];
}

class SerialSetError extends SerialSetState {
  final String message;
  const SerialSetError(this.message);

  @override
  List<Object?> get props => [message];
}
