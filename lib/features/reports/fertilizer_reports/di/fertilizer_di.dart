

import '../../../../core/di/injection.dart';
import '../data/datasources/fertilizer_datasource.dart';
import '../data/repositories/fertilizer_repositories.dart';
import '../domain/repositories/fertilizer_repo.dart';
import '../domain/usecases/fetch_fertilizer_data.dart';
import '../presentation/bloc/fertilizer_bloc.dart';

void initFertilizer() {

  /// 🔹 DataSource
  sl.registerLazySingleton<FertilizerRemoteDataSource>(
        () => FertilizerRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );

  /// 🔹 Repository
  sl.registerLazySingleton<FertilizerRepository>(
        () => FertilizerRepositoryImpl(
      dataSource: sl(),
    ),
  );
//
  /// 🔹 UseCase
  sl.registerLazySingleton(
        () => FetchFertilizerData( repository: sl(),),
  );

  /// 🔹 Bloc
  sl.registerFactory(
        () => FertilizerBloc(fetchFertilizerData: sl(),),
  );
}
