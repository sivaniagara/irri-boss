import '../../../../../core/di/injection.dart';
import '../data/datasources/tdy_valve_status_datasource.dart';
import '../data/repositories/tdy_valve_status_repositories.dart';
import '../domain/repositories/tdy_valve_status_repo.dart';
import '../domain/usecases/tdy_valve_status_data.dart';
import '../presentation/bloc/tdy_valve_status_bloc.dart';



void initTdyValveStatus() {

  /// 🔹 DataSource
  sl.registerLazySingleton<TdyValveStatusRemoteDataSource>(
        () => TdyValveStatusRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );

  /// 🔹 Repository
  sl.registerLazySingleton<TdyValveStatusRepository>(
        () => TdyValveStatusRepositoryImpl(
      dataSource: sl(),
    ),
  );
//
  /// 🔹 UseCase
  sl.registerLazySingleton(
        () => FetchTdyValveStatusData( repository: sl(),),
  );

  /// 🔹 Bloc
  sl.registerFactory(
        () => TdyValveStatusBloc(fetchTdyValveStatusData: sl(),),
  );
}
