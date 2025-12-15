import '../../../core/di/injection.dart';
import '../program_list/data/data_source/program_remote_source.dart';
import '../program_list/data/repositories/program_repository_impl.dart';
import '../program_list/domain/repositories/program_repository.dart';
import '../program_list/domain/usecases/get_programs_usecase.dart';
import '../program_list/presentation/bloc/program_bloc.dart';
import '../program_list/presentation/cubit/controller_tab_cubit.dart';
import '../program_list/presentation/cubit/day_selection_cubit.dart';

void initControllerSettingDependencies() async{
  sl.registerFactory(()=>ProgramBloc(getProgramsUseCase: sl()));
  sl.registerLazySingleton(()=>GetProgramsUseCase(programRepository: sl()));
  sl.registerLazySingleton<ProgramRepository>(
        () => ProgramRepositoryImpl(programRemoteSource: sl()),
  );
  sl.registerLazySingleton<ProgramRemoteSource>(
        () => ProgramRemoteSourceImplements(apiClient: sl()),
  );

  sl.registerFactory(() => ControllerTabCubit());
  sl.registerFactory(() => DaySelectionCubit());

}