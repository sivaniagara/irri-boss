import '../../../core/di/injection.dart';
import '../data/datasources/dealer_dashboard_remote_data_source.dart';
import '../data/datasources/shared_device_data_source.dart';
import '../data/repositories/dealer_dashboard_repository_impl.dart';
import '../data/repositories/shared_devices_repository_impl.dart';
import '../domain/repositories/dealer_dashboard_repository.dart';
import '../domain/repositories/shared_devices_repositories.dart';
import '../domain/usecases/get_dealer_customer_details.dart';
import '../domain/usecases/get_selected_customers.dart';
import '../domain/usecases/get_shared_device_usecase.dart';
import '../presentation/cubit/dealer_list_cubit.dart';

void initDealerDashboardDependencies() {
  // Cubit
  sl.registerFactory(
        () => DealerListCubit(
      getDealerCustomerDetails: sl(),
      getSelectedCustomerDetails: sl(),
      getSharedDevicesUsecase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDealerCustomerDetails(sl()));
  sl.registerLazySingleton(() => GetSelectedCustomerDetails(sl()));

  // Repositories
  sl.registerLazySingleton<DealerDashboardRepository>(
        () => DealerDashboardRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<DealerDashboardRemoteDataSource>(
        () => DealerDashboardRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<SharedDevicesDataSource>(() => SharedDeviceDataSourceImpl());
  sl.registerLazySingleton<SharedDevicesRepository>(() => SharedDevicesRepositoryImpl(sharedDevicesDataSource: sl()));

  sl.registerFactory(() => GetSharedDevicesUsecase(repository: sl()));
}
