import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/program_and_zone_entity.dart';
import '../../domain/usecases/delete_zone_usecase.dart';
import '../../domain/usecases/get_programs_usecase.dart';
import '../pages/controller_program.dart';
part 'program_event.dart';
part 'program_state.dart';

class ProgramBloc extends Bloc<ProgramEvent, ProgramState> {
  final GetProgramsUseCase getProgramsUseCase;
  final DeleteZoneUseCase deleteZoneUseCase;

  ProgramBloc({required this.getProgramsUseCase, required this.deleteZoneUseCase,}) : super(ProgramInitial()) {
    on<FetchPrograms>((event, emit) async {
      print('FetchPrograms calling....');
      emit(ProgramLoading());
      try {
        ProgramParams params = ProgramParams(userId: event.userId, controllerId: event.controllerId);
        // The use case returns an 'Either' type
        final failureOrPrograms = await getProgramsUseCase(params);

        failureOrPrograms.fold(
              (failure) {
            emit(ProgramError("An error occurred: ${failure.toString()}"));
          },
              (listOfPrograms) {
            emit(ProgramLoaded(programs: listOfPrograms));
          },
        );
      } catch (e) {
        emit(ProgramError(e.toString()));
      }
    });

    on<DeleteZone>((event, emit) async{
      final current = state as ProgramLoaded;
      emit(current.copyWith(status: ZoneDeleteStatus.loading));
      DeleteZoneParams deleteZoneParams = DeleteZoneParams(
          userId: event.userId,
          controllerId: event.controllerId,
          programId: event.programId,
          zoneSerialNo: event.zoneSerialNo
      );
      final result = await deleteZoneUseCase(deleteZoneParams);
      result
          .fold(
              (failure){
                emit(current.copyWith(status: ZoneDeleteStatus.failure));
              },
              (unit){
                emit(current.copyWith(status: ZoneDeleteStatus.success));
              }
      );
    });
  }
}
