import '../../../../../core/di/injection.dart';
import '../data/datasources/flow_graph_datasource.dart';
 import '../data/repositories/flow_graph_repositories.dart';
 import '../domain/repositories/flow_graph_repo.dart';
 import '../domain/usecases/flow_graph_data.dart';
 import '../presentation/bloc/flow_graph_bloc.dart';




void initFlowGraph() {

  /// 🔹 DataSource
  sl.registerLazySingleton<FlowGraphRemoteDataSource>(
        () => FlowGraphRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );

  /// 🔹 Repository
  sl.registerLazySingleton<FlowGraphRepository>(
        () => FlowGraphRepositoryImpl(
      dataSource: sl(),
    ),
  );
//
  /// 🔹 UseCase
  sl.registerLazySingleton(
        () => FetchFlowGraphData( repository: sl(),),
  );

  /// 🔹 Bloc
  sl.registerFactory(
        () => FlowGraphBloc(fetchFlowGraphData: sl(),),
  );
}
