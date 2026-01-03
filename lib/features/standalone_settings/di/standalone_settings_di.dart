import 'package:niagara_smart_drip_irrigation/core/di/injection.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/data/datasources/standalone_remote_datasource.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/data/repositories/standalone_repository_impl.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/domain/repositories/standalone_repository.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/domain/usecases/get_standalone_status.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/domain/usecases/send_standalone_config.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/domain/usecases/publish_mqtt_command.dart';
import 'package:niagara_smart_drip_irrigation/features/standalone_settings/presentation/bloc/standalone_bloc.dart';

void initStandaloneSettings() {
  // Use unique instance names to avoid collision with standalone_reports
  
  // Data sources
  sl.registerLazySingleton<StandaloneRemoteDataSource>(
    () => StandaloneRemoteDataSourceImpl(),

  );

  // Repository
  sl.registerLazySingleton<StandaloneRepository>(
    () => StandaloneRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetStandaloneStatus(sl()));
  sl.registerLazySingleton(() => SendStandaloneConfig(sl()));
  sl.registerLazySingleton(() => PublishMqttCommand(sl()));

  // BLoC
  sl.registerFactory(() => StandaloneBloc(
    getStandaloneStatus: sl(),
    sendStandaloneConfig: sl(),
    publishMqttCommand: sl(),
  ), );
}
