import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../../../core/di/injection.dart';
import '../data/datasources/faultmsg_datasource.dart';
import '../data/repositories/faultmsg_repositories.dart';
import '../domain/repositories/faultmsg_repo.dart';
import '../domain/usecases/faultmsg_params.dart';
import '../presentation/bloc/faultmsg_bloc.dart';

void initfaultmsg() {
  // datasource
  sl.registerLazySingleton<faultmsgRemoteDataSource>(
          () => faultmsgRemoteDataSourceImpl(apiClient: sl()));

  // repository
  sl.registerLazySingleton<faultmsgRepository>(() => faultmsgRepositoryImpl(dataSource: sl(), ));

  // usecase
  sl.registerLazySingleton(() => FetchfaultmsgMessages(sl()));

  // bloc
  sl.registerFactory(
          () => faultmsgBloc(fetchfaultmsgMessages: sl()));

  // external
}
