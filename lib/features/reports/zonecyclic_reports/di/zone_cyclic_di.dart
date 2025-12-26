import '../../../../../core/di/injection.dart';
import '../data/datasources/zone_cyclic_datasource.dart';
import '../data/repositories/zone_cyclic_repositories.dart';
import '../domain/repositories/zone_cyclic_repo.dart';
import '../domain/usecases/zone_cyclic_data.dart';
import '../presentation/bloc/zone_cyclic_bloc.dart';
 



void initZoneCyclic() {

  /// 🔹 DataSource
  sl.registerLazySingleton<ZoneCyclicRemoteDataSource>(
        () => ZoneCyclicRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );

  /// 🔹 Repository
  sl.registerLazySingleton<ZoneCyclicRepository>(
        () => ZoneCyclicRepositoryImpl(
      dataSource: sl(),
    ),
  );
//
  /// 🔹 UseCase
  sl.registerLazySingleton(
        () => FetchZoneCyclicData( repository: sl(),),
  );

  /// 🔹 Bloc
  sl.registerFactory(
        () => ZoneCyclicBloc(fetchZoneCyclicData: sl(),),
  );
}
