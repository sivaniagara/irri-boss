import '../../../core/di/injection.dart';
import '../data/datasources/dealer_dashboard_remote_data_source.dart';
import '../data/repositories/dealer_dashboard_repository_impl.dart';
import '../domain/repositories/dealer_dashboard_repository.dart';
import '../domain/usecases/get_dealer_customer_details.dart';
import '../domain/usecases/get_selected_customers.dart';
import '../presentation/cubit/dealer_customer_cubit.dart';

void initDealerDashboardDependencies() {
  // Cubit
  sl.registerFactory(
    () => DealerCustomerCubit(
      getDealerCustomerDetails: sl(),
      getSelectedCustomerDetails: sl(),
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
}
