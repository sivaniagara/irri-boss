


import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/data/datasources/motor_cyclic_datasource.dart';

import '../../../../../core/di/injection.dart';
import '../data/repositories/motor_cyclic_repositories.dart';
import '../domain/repositories/motor_cyclic_repo.dart';
import '../domain/usecases/fetch_motor_cyclic_data.dart';
import '../presentation/bloc/motor_cyclic_bloc.dart';


void initMotorCyclic() {

  /// 🔹 DataSource
  sl.registerLazySingleton<MotorCyclicRemoteDataSource>(
        () => MotorCyclicRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );

  /// 🔹 Repository
  sl.registerLazySingleton<MotorCyclicRepository>(
        () => MotorCyclicRepositoryImpl(
      dataSource: sl(),
    ),
  );
//
  /// 🔹 UseCase
  sl.registerLazySingleton(
        () => FetchMotorCyclicData( repository: sl(),),
  );

  /// 🔹 Bloc
  sl.registerFactory(
        () => MotorCyclicBloc(fetchMotorCyclicData: sl(),),
  );
}
