import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/bloc/template_irrigation_settings_bloc.dart';
import '../../../core/di/injection.dart';
import '../data/data_source/irrigation_settings_remote_source.dart';
import '../data/repositories/irrigation_settings_repository_impl.dart';
import '../domain/repositories/irrigation_settings_repository.dart';
import '../domain/usecases/get_template_irrigation_setting_usecase.dart';
import '../domain/usecases/update_template_irrigation_setting_usecase.dart';

void initIrrigationSettingsDependencies()async{
 sl.registerFactory(() => TemplateIrrigationSettingsBloc(
     getTemplateIrrigationSettingUsecase: sl(),
     updateTemplateIrrigationSettingUsecase: sl(),
 ));
 
 sl.registerLazySingleton(() => GetTemplateIrrigationSettingUsecase(repository: sl()));
 sl.registerLazySingleton(() => UpdateTemplateIrrigationSettingUsecase(repository: sl()));

 sl.registerLazySingleton<IrrigationSettingsRepository>(() => IrrigationSettingsRepositoryImpl(dataSource: sl()));

 sl.registerLazySingleton<IrrigationSettingsRemoteSource>(() => IrrigationSettingsRemoteSourceImpl(apiClient: sl()));
}