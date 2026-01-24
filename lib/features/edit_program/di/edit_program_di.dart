import '../../../core/di/injection.dart';
import '../data/data_source/edit_program_remote_source.dart';
import '../data/repositories/edit_program_repository_impl.dart';
import '../domain/repositories/edit_program_repository.dart';
import '../domain/usecases/get_program_usecase.dart';
import '../domain/usecases/save_program_usecase.dart';
import '../domain/usecases/send_zone_configuration_payload_usecase.dart';
import '../domain/usecases/send_zone_set_payload_usecase.dart';
import '../presentation/bloc/edit_program_bloc.dart';

void initEditProgramDependencies() async{
  sl.registerFactory(()=> EditProgramBloc(
      getProgramUsecase: sl(),
      saveProgramUsecase: sl(),
    sendZoneConfigurationPayloadUsecase: sl(),
    sendZoneSetPayloadUsecase: sl(),
  ));
  sl.registerLazySingleton(()=>GetProgramUsecase(repository: sl()));
  sl.registerLazySingleton(()=>SaveProgramUsecase(repository: sl()));
  sl.registerLazySingleton(()=>SendZoneConfigurationPayloadUsecase(repository: sl()));
  sl.registerLazySingleton(()=>SendZoneSetPayloadUsecase(repository: sl()));
  sl.registerLazySingleton<EditProgramRepository>(
        () => GetProgramRepositoryImpl(remoteSource: sl()),
  );
  sl.registerLazySingleton<EditProgramRemoteSource>(
        () => EditProgramRemoteSourceImpl(
            apiClient: sl(),
          mqttManager: sl()
        ),
  );

  // /// Edit Zone Sub Module
  // sl.registerFactory(()=>EditZoneBloc(
  //   getZoneNodesUseCase: sl(),
  //   editZoneNodesUseCase: sl(),
  //   submitZoneConfigurationUsecase: sl(),
  //   submitWhileEditZoneConfigurationUseCase: sl(),
  // ));
  // sl.registerLazySingleton(()=>GetZoneConfigurationUseCase(repository: sl()));
  // sl.registerLazySingleton(()=>EditZoneConfigurationUseCase(repository: sl()));
  // sl.registerLazySingleton(()=>SubmitZoneConfigurationUseCase(repository: sl()));
  // sl.registerLazySingleton(()=>SubmitWhileEditZoneConfigurationUseCase(repository: sl()));
  // sl.registerLazySingleton<ZoneConfigurationRepository>(
  //       () => ZoneConfigurationRepositoryImpl(zoneConfigurationRemoteSource: sl()),
  // );
  // sl.registerLazySingleton<ZoneConfigurationRemoteSource>(
  //       () => ZoneConfigurationRemoteSourceImpl(apiClient: sl()),
  // );
  //
  //
  // /// Common Id Settings Sub Module
  // sl.registerFactory(()=> CommonIdSettingsBloc(
  //   getCommonIdSettingsUsecase: sl(), submitCategoryUsecase: sl(),
  // ));
  // sl.registerLazySingleton(()=> GetCommonIdSettingsUsecase(commonIdSettingsRepository: sl()));
  // sl.registerLazySingleton(()=> SubmitCategoryUsecase(commonIdSettingsRepository: sl()));
  // sl.registerLazySingleton<CommonIdSettingsRepository>(
  //       () => CommonIdSettingsRepositoryImpl(
  //     commonIdSettingsDataSource: sl(),
  //   ),
  // );
  // sl.registerLazySingleton<CommonIdSettingsRemoteSource>(()=> CommonIdSettingsDataSourceImpl(apiClient: sl()));
}