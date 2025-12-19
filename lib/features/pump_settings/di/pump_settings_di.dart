import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/usecsases/send_settings_usecase.dart';

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
import '../presentation/cubit/pump_settings_cubit.dart';
import '../presentation/cubit/view_pump_settings_cubit.dart';
import '../utils/pump_settings_dispatcher.dart';

void initPumpSettingsDependencies() {
  sl.registerLazySingleton<PumpSettingsDataSources>(() => PumpSettingsDataSourcesImpl(apiClient: sl()));
  sl.registerLazySingleton<PumpSettingsRepository>(() => PumpSettingsRepositoryImpl(pumpSettingsDataSources: sl()));
  sl.registerLazySingleton(() => GetPumpSettingsMenuUsecase(pumpSettingsRepository: sl()));
  sl.registerFactory(() => PumpSettingsMenuBloc(getSettingsMenuUsecase: sl()));

  sl.registerLazySingleton(() => GetPumpSettingsUsecase(pumpSettingsRepository: sl()));
  sl.registerLazySingleton(() => SendPumpSettingsUsecase(pumpSettingsRepository: sl()));
  sl.registerFactory(() => PumpSettingsCubit(getPumpSettingsUsecase: sl(), sendPumpSettingsUsecase: sl()));

  sl.registerLazySingleton(() => GetNotificationsUsecase(pumpSettingsRepository: sl()));
  sl.registerLazySingleton(() => SubscribeNotificationsUsecase(pumpSettingsRepository: sl()));
  sl.registerFactory(() => NotificationsPageCubit(getNotificationsUsecase: sl(), subscribeNotificationsUsecase: sl()));

  sl.registerFactory<ViewPumpSettingsCubit>(() => ViewPumpSettingsCubit(),);
  sl.registerFactory<PumpSettingsDispatcher>(() => PumpSettingsDispatcher(sl<ViewPumpSettingsCubit>()),
  );
}