
import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/data/datasources/motor_cyclic_datasource.dart';
import '../../../../../core/di/injection.dart';
import '../data/datasources/zone_duration_datasource.dart';
import '../data/repositories/zone_duration_repositories.dart';
import '../domain/repositories/zone_duration_repo.dart';
import '../domain/usecases/fetch_zone_duration_data.dart';
import '../presentation/bloc/zone_duration_bloc.dart';

 void initZoneDuration() {

  /// 🔹 DataSource
  sl.registerLazySingleton<ZoneDurationRemoteDataSource>(
        () => ZoneDurationRemoteDataSourceImpl(
      apiClient: sl(),
    ),
  );

  /// 🔹 Repository
  sl.registerLazySingleton<ZoneDurationRepository>(
        () => ZoneDurationRepositoryImpl(
      dataSource: sl(),
    ),
  );
//
  /// 🔹 UseCase
  sl.registerLazySingleton(
        () => FetchZoneDurationData( repository: sl(),),
  );

  /// 🔹 Bloc
  sl.registerFactory(
        () => ZoneDurationBloc(fetchZoneDurationData: sl(),),
  );
}
