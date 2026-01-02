

import '../../../../core/di/injection.dart';
import '../data/datasources/moisture_datasource.dart';
import '../data/repositories/moisture_repositories.dart';
import '../domain/repositories/moisture_repo.dart';
import '../domain/usecases/moisture_data.dart';
import '../presentation/bloc/moisture_bloc.dart';

void initMoisture() {

  /// 🔹 DataSource
  sl.registerLazySingleton<MoistureRemoteDataSource>(
        () => MoistureRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );

  /// 🔹 Repository
  sl.registerLazySingleton<MoistureRepository>(
        () => MoistureRepositoryImpl(
      dataSource: sl(),
    ),
  );
//
  /// 🔹 UseCase
  sl.registerLazySingleton(
        () => FetchMoistureData( repository: sl(),),
  );

  /// 🔹 Bloc
  sl.registerFactory(
        () => MoistureBloc(fetchMoistureData: sl(),),
  );
}
