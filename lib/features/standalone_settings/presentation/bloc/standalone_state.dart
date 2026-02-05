import 'package:equatable/equatable.dart';
import '../../domain/entities/standalone_entity.dart';

abstract class StandaloneState extends Equatable {
  const StandaloneState();

  @override
  List<Object?> get props => [];
}

class StandaloneInitial extends StandaloneState {}

class StandaloneLoading extends StandaloneState {}

class StandaloneLoaded extends StandaloneState {
  final String userId;
  final String controllerId;
  final String deviceId;
  final String subUserId;
  final StandaloneEntity data;

  const StandaloneLoaded({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.subUserId,
    required this.data,
  });

  StandaloneLoaded copyWith({
    StandaloneEntity? newData,
  }) {
    return StandaloneLoaded(
      userId: userId,
      controllerId: controllerId,
      deviceId: deviceId,
      subUserId: subUserId,
      data: newData ?? data,
    );
  }

  @override
  List<Object?> get props => [userId, controllerId, deviceId, subUserId, data];
}

class StandaloneSuccess extends StandaloneState {
  final String message;
  final StandaloneEntity data;

  const StandaloneSuccess(this.message, this.data);

  @override
  List<Object?> get props => [message, data];
}

class StandaloneError extends StandaloneState {
  final String message;

  const StandaloneError(this.message);

  @override
  List<Object?> get props => [message];
}
