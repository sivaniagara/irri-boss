part of 'program_bloc.dart';

abstract class ProgramEvent {}

class FetchPrograms extends ProgramEvent {
  final String userId;
  final String controllerId;
  FetchPrograms({required this.userId, required this.controllerId});
}
