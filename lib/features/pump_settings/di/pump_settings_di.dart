import 'package:niagara_smart_drip_irrigation/features/pump_settings/data/datasources/pump_settings_datasources.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/data/repositories/pump_settings_repository_impl.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/repositories/pump_settings_repository.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/get_menu_items.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/get_settings_menu_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/bloc/pump_settings_menu_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/presentation/cubit/pump_settings_cubit.dart';

import '../../../core/di/injection.dart';
import '../../mqtt/utils/mqtt_message_helper.dart';

void initPumpSettingsDependencies() {
  sl.registerLazySingleton<PumpSettingsDataSources>(() => PumpSettingsDataSourcesImpl(apiClient: sl()));
  sl.registerLazySingleton<PumpSettingsRepository>(() => PumpSettingsRepositoryImpl(pumpSettingsDataSources: sl()));
  sl.registerLazySingleton(() => GetPumpSettingsMenuUsecase(pumpSettingsRepository: sl()));
  sl.registerFactory(() => PumpSettingsMenuBloc(getSettingsMenuUsecase: sl()));

  sl.registerLazySingleton(() => GetPumpSettingsUsecase(pumpSettingsRepository: sl()));
  // sl.registerFactory(() => PumpSettingsBloc(getPumpSettingsUsecase: sl()));
  sl.registerFactory(() => PumpSettingsCubit(getPumpSettingsUsecase: sl()));
  // sl.registerLazySingleton<MessageDispatcher>(() => DashboardMessageDispatcher(dashboardBloc: sl<DashboardBloc>()));
}