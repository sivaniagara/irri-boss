import '../../../../core/di/injection.dart';
import '../data/datasources/voltage_datasource.dart';
import '../data/repositories/voltage_repositories.dart';
import '../domain/repositories/voltage_repo.dart';
import '../domain/usecases/fetchvoltagegraphdata.dart';
import '../presentation/bloc/voltage_bloc.dart';

void initVoltageGraph() {

  /// 🔹 DataSource
  sl.registerLazySingleton<VoltageRemoteDataSource>(
        () => VoltageRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );

  /// 🔹 Repository
  sl.registerLazySingleton<VoltageGraphRepository>(
        () => VoltageGraphRepositoryImpl(
      dataSource: sl(),
    ),
  );
//
  /// 🔹 UseCase
  sl.registerLazySingleton(
        () => FetchVoltageGraphData( repository: sl(),),
  );

  /// 🔹 Bloc
  sl.registerFactory(
        () => VoltageGraphBloc(fetchVoltageGraphData: sl(),
    ),
  );
}
