part of 'program_bloc.dart';


abstract class ProgramState {}

class ProgramInitial extends ProgramState {}

class ProgramLoading extends ProgramState {}

class ProgramLoaded extends ProgramState {
  final List<ProgramAndZoneEntity> programs;
  ZoneDeleteStatus zoneDeleteStatus;

  ProgramLoaded({
    required this.programs,
    this.zoneDeleteStatus = ZoneDeleteStatus.initial,
  });

  ProgramLoaded copyWith({ZoneDeleteStatus? status}){
    return ProgramLoaded(programs: programs, zoneDeleteStatus : status ?? zoneDeleteStatus,);
  }
}

class ProgramError extends ProgramState {
  final String message;

  ProgramError(this.message);
}
