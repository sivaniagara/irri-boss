part of 'edit_zone_bloc.dart';

abstract class EditZoneState {}

class EditZoneInitial extends EditZoneState {}

class EditZoneLoading extends EditZoneState {}

class EditZoneLoaded extends EditZoneState {
  final String programId;
  final String userId;
  final String controllerId;
  final ZoneConfigurationEntity zoneNodes;
  EditZoneLoaded({
    required this.zoneNodes,
    required this.programId,
    required this.userId,
    required this.controllerId,
  });
}

class EditZoneError extends EditZoneState {
  final String message;
  EditZoneError(this.message);
}

class EditValveLimitExceeded extends EditZoneState {
  final String message;
  EditValveLimitExceeded({required this.message});
}

