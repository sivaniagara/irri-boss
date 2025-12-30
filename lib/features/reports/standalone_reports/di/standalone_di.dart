import '../../../../../core/di/injection.dart';
import '../data/datasources/standalone_datasource.dart';
import '../data/repositories/standalone_repositories.dart';
import '../domain/repositories/standalone_repo.dart';
import '../domain/usecases/standalone_data.dart';
import '../presentation/bloc/standalone_bloc.dart';


void initStandalone() {

  /// 🔹 DataSource
  sl.registerLazySingleton<StandaloneRemoteDataSource>(
        () => StandaloneRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );

  /// 🔹 Repository
  sl.registerLazySingleton<StandaloneRepository>(
        () => StandaloneRepositoryImpl(
      dataSource: sl(),
    ),
  );
//
  /// 🔹 UseCase
  sl.registerLazySingleton(
        () => FetchStandaloneData( repository: sl(),),
  );

  /// 🔹 Bloc
  sl.registerFactory(
        () => StandaloneBloc(fetchStandaloneData: sl(),),
  );
}
