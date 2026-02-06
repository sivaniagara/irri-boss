import '../../../../../../core/di/injection.dart';
import '../data/data_source/serial_set_remote_source.dart';
import '../data/repositories/serial_set_repository_impl.dart';
import '../domain/repositories/serial_set_repository.dart';
import '../presentation/bloc/serial_set_bloc.dart';

void initSerialSetDependencies() {
  if (!sl.isRegistered<SerialSetRemoteSource>()) {
    sl.registerLazySingleton<SerialSetRemoteSource>(() => SerialSetRemoteSourceImpl(apiClient: sl()));
  }

  if (!sl.isRegistered<SerialSetRepository>()) {
    sl.registerLazySingleton<SerialSetRepository>(() => SerialSetRepositoryImpl(remoteSource: sl()));
  }

  sl.registerFactory(() => SerialSetBloc(repository: sl()));
}
