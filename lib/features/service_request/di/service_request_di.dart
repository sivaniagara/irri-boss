import '../../../core/di/injection.dart';
import '../data/datasources/service_request_remote_datasource.dart';
import '../data/repositories/service_request_repository_impl.dart';
import '../domain/repositories/service_request_repository.dart';
import '../presentation/bloc/service_request_bloc.dart';

void initServiceRequestDependencies() {
  sl.registerFactory(() => ServiceRequestBloc(repository: sl()));
  
  sl.registerLazySingleton<ServiceRequestRepository>(
    () => ServiceRequestRepositoryImpl(remoteDataSource: sl()),
  );
  
  sl.registerLazySingleton<ServiceRequestRemoteDataSource>(
    () => ServiceRequestRemoteDataSourceImpl(apiClient: sl()),
  );
}
