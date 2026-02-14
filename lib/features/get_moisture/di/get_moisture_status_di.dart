import '../../../core/di/injection.dart';
import '../data/datasources/get_moisture_status_remote_datasource.dart';
import '../data/repositories/get_moisture_status_repository_impl.dart';
import '../domain/repositories/get_moisture_status_repository.dart';
import '../domain/usecases/get_moisture_status.dart';
import '../presentation/bloc/get_moisture_status_bloc.dart';

void initGetMoistureStatus() {
  // BLoC
  sl.registerFactory(() => GetMoistureStatusBloc(getMoistureStatus: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetMoistureStatus(sl()));

  // Repository
  sl.registerLazySingleton<GetMoistureStatusRepository>(
    () => GetMoistureStatusRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<GetMoistureStatusRemoteDataSource>(
    () => GetMoistureStatusRemoteDataSourceImpl(apiClient: sl()),
  );
}
