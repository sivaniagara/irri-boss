part of 'edit_zone_bloc.dart';

abstract class EditZoneEvent {}

class AddZone extends EditZoneEvent {
  final String userId;
  final String controllerId;
  AddZone({required this.userId, required this.controllerId});
}
