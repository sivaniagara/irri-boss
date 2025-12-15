part of 'program_bloc.dart';


abstract class ProgramState {}

class ProgramInitial extends ProgramState {}

class ProgramLoading extends ProgramState {}

class ProgramLoaded extends ProgramState {
  final List<ProgramAndZoneEntity> programs;

  ProgramLoaded(this.programs);
}

class ProgramError extends ProgramState {
  final String message;

  ProgramError(this.message);
}
