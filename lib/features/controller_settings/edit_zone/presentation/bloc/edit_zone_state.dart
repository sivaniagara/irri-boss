part of 'edit_zone_bloc.dart';

abstract class EditZoneState {}

class EditZoneInitial extends EditZoneState {}

class EditZoneLoading extends EditZoneState {}

class EditZoneLoaded extends EditZoneState {
  final ZoneConfigurationEntity zoneNodes;
  EditZoneLoaded(this.zoneNodes);
}

class EditZoneError extends EditZoneState {
  final String message;
  EditZoneError(this.message);
}
