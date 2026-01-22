import '../../../core/di/injection.dart';
import '../data/data_sources/valve_flow_remote_source.dart';
import '../data/repositories/valve_flow_repository_impl.dart';
import '../domain/repositories/valve_flow_repository.dart';
import '../presentation/bloc/valve_flow_bloc.dart';

void initValveFlowDependencies() {
  sl.registerFactory(() => ValveFlowBloc(repository: sl()));
  
  sl.registerLazySingleton<ValveFlowRepository>(() => ValveFlowRepositoryImpl(remoteSource: sl()),
  );
  
  sl.registerLazySingleton<ValveFlowRemoteSource>(() => ValveFlowRemoteSourceImpl(apiClient: sl()),
  );
}
