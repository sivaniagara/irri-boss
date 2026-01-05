import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/usecases/get_valve_flow_setting_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/usecases/publish_valve_flow_sms_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/usecases/save_valve_flow_settings_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/presentation/bloc/template_irrigation_settings_bloc.dart';
import '../../../core/di/injection.dart';
import '../data/data_source/irrigation_settings_remote_source.dart';
import '../data/repositories/irrigation_settings_repository_impl.dart';
import '../domain/repositories/irrigation_settings_repository.dart';
import '../domain/usecases/get_template_irrigation_setting_usecase.dart';

void initIrrigationSettingsDependencies()async{
 sl.registerFactory(() => TemplateIrrigationSettingsBloc(
     getTemplateIrrigationSettingUsecase: sl(),
     getValveFlowSettingUsecase: sl(),
     publishValveFlowSmsUsecase: sl(),
     saveValveFlowSettingsUsecase: sl()
 ));
 
 sl.registerLazySingleton(() => GetTemplateIrrigationSettingUsecase(repository: sl()));
 sl.registerLazySingleton(() => GetValveFlowSettingUsecase(repository: sl()));
 sl.registerLazySingleton(() => PublishValveFlowSmsUsecase(repository: sl()));
 sl.registerLazySingleton(() => SaveValveFlowSettingsUsecase(repository: sl()));
 
 sl.registerLazySingleton<IrrigationSettingsRepository>(() => IrrigationSettingsRepositoryImpl(dataSource: sl()));

 sl.registerLazySingleton<IrrigationSettingsRemoteSource>(() => IrrigationSettingsRemoteSourceImpl(apiClient: sl()));
}