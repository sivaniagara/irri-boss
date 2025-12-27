
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/domain/usecases/fetch_program_zone_sets_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/presentation/bloc/water_fertilizer_setting_bloc.dart';

import '../../../core/di/injection.dart';
import '../data/data_source/water_fertilizer_settings_remote_source.dart';
import '../data/repositories/water_fertilizer_settings_repository_impl.dart';
import '../domain/repositories/water_fertilizer_settings_repository.dart';
import '../domain/usecases/fetch_zone_set_setting_usecase.dart';

void initWaterFertilizerSettingsDependencies()async{
  sl.registerFactory(() => WaterFertilizerSettingBloc(
      fetchProgramZoneSetsUsecase: sl(),
    fetchZoneSetSettingUsecase: sl(),
  ));
  sl.registerLazySingleton(()=> FetchProgramZoneSetsUsecase(repository: sl()));
  sl.registerLazySingleton(()=> FetchZoneSetSettingUsecase(repository: sl()));
  sl.registerLazySingleton<WaterFertilizerSettingsRepository>(()=> WaterFertilizerSettingsRepositoryImpl(remoteSource: sl()));
  sl.registerLazySingleton<WaterFertilizerSettingsRemoteSource>(()=> WaterFertilizerSettingsRemoteSourceImpl(apiClient: sl()));
}