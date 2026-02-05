import '../../../../core/di/injection.dart';
import '../data/data_sources/selling_device_remote_datasource.dart';
import '../data/repositories/selling_device_repository_impl.dart';
import '../domain/repositories/selling_device_repository.dart';
import '../presentation/cubit/selling_device_cubit.dart';

void initSellingDeviceDependencies() {
  sl.registerLazySingleton<SellingDeviceRemoteDataSource>(
        () => SellingDeviceRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<SellingDeviceRepository>(
        () => SellingDeviceRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => SellingDeviceCubit(repository: sl()));
}
