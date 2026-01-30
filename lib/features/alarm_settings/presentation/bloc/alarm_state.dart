import 'package:equatable/equatable.dart';
import '../../domain/entities/alarm_entity.dart';

abstract class AlarmState extends Equatable {
  const AlarmState();
  @override
  List<Object?> get props => [];
}

class AlarmInitial extends AlarmState {}

class AlarmLoading extends AlarmState {
  final bool isSaving;
  const AlarmLoading({this.isSaving = false});

  @override
  List<Object?> get props => [isSaving];
}

class AlarmLoaded extends AlarmState {
  final String userId;
  final String controllerId;
  final String deviceId;
  final String subUserId;
  final AlarmEntity entity;

  const AlarmLoaded({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.subUserId,
    required this.entity,
  });

  AlarmLoaded copyWith({
    AlarmEntity? updatedEntity,
  }) {
    return AlarmLoaded(
      userId: userId,
      controllerId: controllerId,
      deviceId: deviceId,
      subUserId: subUserId,
      entity: updatedEntity ?? entity,
    );
  }

  @override
  List<Object?> get props => [userId, controllerId, deviceId, subUserId, entity];
}

class AlarmSuccess extends AlarmState {
  final String message;
  final AlarmEntity data;

  const AlarmSuccess({required this.message, required this.data});

  @override
  List<Object?> get props => [message, data];
}

class AlarmError extends AlarmState {
  final String message;
  const AlarmError({required this.message});

  @override
  List<Object?> get props => [message];
}
