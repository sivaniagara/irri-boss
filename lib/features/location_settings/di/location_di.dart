import '../../../../core/di/injection.dart';
import '../data/datasources/location_remote_datasource.dart';
import '../data/repositories/location_repository_impl.dart';
import '../domain/repositories/location_repository.dart';
import '../presentation/cubit/location_cubit.dart';

void initLocationSettings() {
  // Data sources
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(apiClient: sl()),
  );

  // Repository
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(remoteDataSource: sl()),
  );

  // Cubit
  sl.registerFactory(() => LocationCubit(sl()));
}
