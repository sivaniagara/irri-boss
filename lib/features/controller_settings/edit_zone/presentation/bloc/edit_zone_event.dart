part of 'edit_zone_bloc.dart';

abstract class EditZoneEvent {}

class AddZone extends EditZoneEvent {
  final String userId;
  final String controllerId;
  final String programId;
  AddZone({required this.userId, required this.controllerId, required this.programId});
}

class ApplyValveSelection extends EditZoneEvent {
  final List<NodeEntity> valves;
  ApplyValveSelection(this.valves);
}

class SubmitZone extends EditZoneEvent {}