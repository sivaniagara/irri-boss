import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/edit_zone/domain/usecases/get_zone_configuration_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/edit_zone/domain/usecases/submit_while_edit_zone_configuration.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/edit_zone/domain/usecases/submit_zone_configuration_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/edit_zone/presentation/bloc/edit_zone_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/domain/usecases/delete_zone_usecase.dart';
import '../../../core/di/injection.dart';
import '../../program_settings/sub_module/edit_zone/data/data_source/zone_configuration_remote_source.dart';
import '../../program_settings/sub_module/edit_zone/data/repositories/zone_configuration_repository_impl.dart';
import '../../program_settings/sub_module/edit_zone/domain/repositories/zone_configuration_repository.dart';
import '../../program_settings/sub_module/edit_zone/domain/usecases/edit_zone_configuration_usecase.dart';
import '../../program_settings/data/data_source/program_remote_source.dart';
import '../../program_settings/data/repositories/program_repository_impl.dart';
import '../../program_settings/domain/repositories/program_repository.dart';
import '../../program_settings/domain/usecases/get_programs_usecase.dart';
import '../../program_settings/presentation/bloc/program_bloc.dart';

void initProgramSettingDependencies() async{
  sl.registerFactory(()=>ProgramBloc(getProgramsUseCase: sl(), deleteZoneUseCase: sl()));
  sl.registerLazySingleton(()=>GetProgramsUseCase(programRepository: sl()));
  sl.registerLazySingleton(()=>DeleteZoneUseCase(programRepository: sl()));
  sl.registerLazySingleton<ProgramRepository>(
        () => ProgramRepositoryImpl(programRemoteSource: sl()),
  );
  sl.registerLazySingleton<ProgramRemoteSource>(
        () => ProgramRemoteSourceImplements(apiClient: sl()),
  );

  /// Edit Zone Sub Module
  sl.registerFactory(()=>EditZoneBloc(
    getZoneNodesUseCase: sl(),
    editZoneNodesUseCase: sl(),
    submitZoneConfigurationUsecase: sl(),
    submitWhileEditZoneConfigurationUseCase: sl(),
  ));
  sl.registerLazySingleton(()=>GetZoneConfigurationUseCase(repository: sl()));
  sl.registerLazySingleton(()=>EditZoneConfigurationUseCase(repository: sl()));
  sl.registerLazySingleton(()=>SubmitZoneConfigurationUseCase(repository: sl()));
  sl.registerLazySingleton(()=>SubmitWhileEditZoneConfigurationUseCase(repository: sl()));
  sl.registerLazySingleton<ZoneConfigurationRepository>(
        () => ZoneConfigurationRepositoryImpl(zoneConfigurationRemoteSource: sl()),
  );
  sl.registerLazySingleton<ZoneConfigurationRemoteSource>(
        () => ZoneConfigurationRemoteSourceImpl(apiClient: sl()),
  );


  /// Common Id Settings Sub Module
  // sl.registerFactory(()=> CommonIdSettingsBloc(
  //     getCommonIdSettingsUsecase: sl(), submitCategoryUsecase: sl(),
  // ));
  // sl.registerLazySingleton(()=> GetCommonIdSettingsUsecase(commonIdSettingsRepository: sl()));
  // sl.registerLazySingleton(()=> SubmitCategoryUsecase(commonIdSettingsRepository: sl()));
  // sl.registerLazySingleton<CommonIdSettingsRepository>(
  //       () => CommonIdSettingsRepositoryImpl(
  //      commonIdSettingsDataSource: sl(),
  //   ),
  // );
  // sl.registerLazySingleton<CommonIdSettingsRemoteSource>(()=> CommonIdSettingsDataSourceImpl(apiClient: sl()));

}