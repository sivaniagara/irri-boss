part of 'program_bloc.dart';

abstract class ProgramEvent {}

class FetchPrograms extends ProgramEvent {
  final String userId;
  final String controllerId;
  FetchPrograms({required this.userId, required this.controllerId});
}

class DeleteZone extends ProgramEvent{
  final String userId;
  final String controllerId;
  final String programId;
  final String zoneSerialNo;

  DeleteZone({
    required this.userId,
    required this.controllerId,
    required this.programId,
    required this.zoneSerialNo,
  });
}
