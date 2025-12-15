import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/program_and_zone_entity.dart';
import '../../domain/usecases/get_programs_usecase.dart';
part 'program_event.dart';
part 'program_state.dart';

class ProgramBloc extends Bloc<ProgramEvent, ProgramState> {
  final GetProgramsUseCase getProgramsUseCase;

  ProgramBloc({required this.getProgramsUseCase}) : super(ProgramInitial()) {
    on<FetchPrograms>((event, emit) async {
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
            emit(ProgramLoaded(listOfPrograms));
          },
        );
      } catch (e) {
        emit(ProgramError(e.toString()));
      }
    });
  }
}
