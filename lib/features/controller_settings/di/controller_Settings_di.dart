import 'package:niagara_smart_drip_irrigation/features/controller_settings/edit_zone/domain/usecases/get_zone_configuration_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/edit_zone/presentation/bloc/edit_zone_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/program_list/presentation/cubit/controller_context_cubit.dart';

import '../../../core/di/injection.dart';
import '../edit_zone/data/data_source/zone_configuration_remote_source.dart';
import '../edit_zone/data/repositories/zone_configuration_repository_impl.dart';
import '../edit_zone/domain/repositories/zone_configuration_repository.dart';
import '../program_list/data/data_source/program_remote_source.dart';
import '../program_list/data/repositories/program_repository_impl.dart';
import '../program_list/domain/repositories/program_repository.dart';
import '../program_list/domain/usecases/get_programs_usecase.dart';
import '../program_list/presentation/bloc/program_bloc.dart';
import '../program_list/presentation/cubit/controller_tab_cubit.dart';

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

  sl.registerFactory(()=>EditZoneBloc(getZoneNodesUseCase: sl()));
  sl.registerLazySingleton(()=>GetZoneConfigurationUseCase(repository: sl()));
  sl.registerLazySingleton<ZoneConfigurationRepository>(
        () => ZoneConfigurationRepositoryImpl(zoneConfigurationRemoteSource: sl()),
  );
  sl.registerLazySingleton<ZoneConfigurationRemoteSource>(
        () => ZoneConfigurationRemoteSourceImpl(apiClient: sl()),
  );



}