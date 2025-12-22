


import '../../../../../core/di/injection.dart';
import '../data/datasources/power_datasource.dart';
import '../data/repositories/power_repositories.dart';
import '../domain/repositories/power_repo.dart';
import '../domain/usecases/fetchpowergraphdata.dart';
import '../presentation/bloc/power_bloc.dart';

void initPowerGraph() {

  /// 🔹 DataSource
  sl.registerLazySingleton<PowerRemoteDataSource>(
        () => PowerRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );

  /// 🔹 Repository
  sl.registerLazySingleton<PowerGraphRepository>(
        () => PowerGraphRepositoryImpl(
      dataSource: sl(),
    ),
  );
//
  /// 🔹 UseCase
  sl.registerLazySingleton(
        () => FetchPowerGraphData( repository: sl(),),
  );

  /// 🔹 Bloc
  sl.registerFactory(
        () => PowerGraphBloc(fetchPowerGraphData: sl(),
    ),
  );
}
