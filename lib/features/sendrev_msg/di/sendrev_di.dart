import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:niagara_smart_drip_irrigation/features/sendrev_msg/domain/repositories/sendrev_repo.dart';

import '../../../core/di/injection.dart';
import '../data/datasources/sendrev_datasource.dart';
import '../data/repositories/sendrev_repositories.dart';
import '../domain/usecases/sendrev_params.dart';
import '../domain/usecases/sendrevmsgParams.dart';
import '../presentation/bloc/sendrev_bloc.dart';

void initSendRev() {
  // datasource
  sl.registerLazySingleton<SendRevRemoteDataSource>(
          () => SendRevRemoteDataSourceImpl(apiClient: sl()));

  // repository
  sl.registerLazySingleton<SendrevRepository>(() => SendrevRepositoryImpl(dataSource: sl(), ));

  // usecase
  sl.registerLazySingleton(() => FetchSendRevMessages(sl()));

  // bloc
  sl.registerFactory(
          () => SendrevBloc(fetchSendRevMessages: sl()));

  // external
}
