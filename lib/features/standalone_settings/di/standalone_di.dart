import '../../../core/di/injection.dart';
import '../data/datasources/standalone_remote_datasource.dart';
import '../data/repositories/standalone_repository_impl.dart';
import '../domain/repositories/standalone_repository.dart';
import '../domain/usecases/get_standalone_status.dart';
import '../domain/usecases/send_standalone_config.dart';
import '../domain/usecases/publish_mqtt_command.dart';
import '../presentation/bloc/standalone_bloc.dart';

void initStandaloneDependencies() {
  // BLoC
  sl.registerFactory(() => StandaloneBloc(
    getStandaloneStatus: sl(),
    sendStandaloneConfig: sl(),
    publishMqttCommand: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetStandaloneStatus(sl()));
  sl.registerLazySingleton(() => SendStandaloneConfig(sl()));
  sl.registerLazySingleton(() => PublishMqttCommand(sl()));

  // Repository
  sl.registerLazySingleton<StandaloneRepository>(
        () => StandaloneRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<StandaloneRemoteDataSource>(
        () => StandaloneRemoteDataSourceImpl(sl(), sl()),
  );
}
