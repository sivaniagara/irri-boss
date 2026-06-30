import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/send_settings_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/update_menu_status.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/verify_menu_password_usecase.dart';

import '../../../core/di/injection.dart';
import '../data/datasources/pump_settings_datasources.dart';
import '../data/repositories/pump_settings_repository_impl.dart';
import '../domain/repositories/pump_settings_repository.dart';
import '../domain/usecsases/get_menu_items.dart';
import '../domain/usecsases/get_notifications_usecase.dart';
import '../domain/usecsases/get_settings_menu_usecase.dart';
import '../domain/usecsases/subscribe_notifications_usecase.dart';
import '../presentation/bloc/pump_settings_menu_bloc.dart';
import '../presentation/cubit/notifications_cubit.dart';
import '../presentation/cubit/pump_settings_view_response_cubit.dart';
import '../presentation/cubit/pump_settings_cubit.dart';
import '../presentation/cubit/view_pump_settings_cubit.dart';
import '../utils/pump_settings_dispatcher.dart';

void initPumpSettingsDependencies() {
  sl.registerLazySingleton<PumpSettingsDataSources>(
          () => PumpSettingsDataSourcesImpl(apiClient: sl()));
  sl.registerLazySingleton<PumpSettingsRepository>(
          () => PumpSettingsRepositoryImpl(pumpSettingsDataSources: sl()));
  sl.registerLazySingleton(
          () => GetPumpSettingsMenuUsecase(pumpSettingsRepository: sl()));
  sl.registerLazySingleton(
          () => UpdateMenuStatusUsecase(pumpSettingsRepository: sl()));
  sl.registerLazySingleton(
          () => VerifyMenuPasswordUsecase(repository: sl()));

  sl.registerFactory(() => PumpSettingsMenuBloc(
    getSettingsMenuUsecase: sl(),
    updateMenuStatusUsecase: sl(),
    verifyMenuPasswordUsecase: sl(),
  ));

  sl.registerLazySingleton(
          () => GetPumpSettingsUsecase(pumpSettingsRepository: sl()));
  sl.registerLazySingleton(
          () => SendPumpSettingsUsecase(pumpSettingsRepository: sl()));

  // ✅ CHANGED: registerFactory → registerLazySingleton
  // This ensures the SAME cubit instance is shared between:
  //   - PumpSettingsPage (via BlocProvider.value)
  //   - PumpSettingsDispatcher (receives BLE/MQTT updates)
  // So when BLE payload arrives, it updates the state that the UI is listening to.
  sl.registerLazySingleton(() => PumpSettingsCubit(
    getPumpSettingsUsecase: sl(),
    sendPumpSettingsUsecase: sl(),
    sharedPreferences: sl(),
  ));

  sl.registerLazySingleton(
          () => GetNotificationsUsecase(pumpSettingsRepository: sl()));
  sl.registerLazySingleton(
          () => SubscribeNotificationsUsecase(pumpSettingsRepository: sl()));
  sl.registerFactory(() => NotificationsPageCubit(
      getNotificationsUsecase: sl(),
      subscribeNotificationsUsecase: sl()));

  sl.registerFactory<ViewPumpSettingsCubit>(() => ViewPumpSettingsCubit());
  sl.registerLazySingleton<PumpSettingsViewResponseCubit>(
          () => PumpSettingsViewResponseCubit());

  // ✅ PumpSettingsDispatcher now holds the singleton PumpSettingsCubit
  // so onNewViewSettings() updates the exact same state the UI observes
  sl.registerLazySingleton<PumpSettingsDispatcher>(() => PumpSettingsDispatcher(
    cubit: sl<ViewPumpSettingsCubit>(),
    pumpSettings: sl<PumpSettingsViewResponseCubit>(),
    pumpSettingsCubit: sl<PumpSettingsCubit>(),
  ));
}