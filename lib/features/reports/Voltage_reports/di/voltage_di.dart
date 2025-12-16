import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/domain/usecases/voltage_params.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/bloc/voltage_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/sendrev_msg/domain/repositories/sendrev_repo.dart';

import '../../../../core/di/injection.dart';
import '../data/datasources/voltage_datasource.dart';
import '../data/repositories/voltage_repositories.dart';

void initVoltGraph() {
  // datasource
  sl.registerLazySingleton<VoltageRemoteDataSource>(
          () => VoltageGraphRepositoryImpl(dataSource: null));

  // repository
  sl.registerLazySingleton<SendrevRepository>(() => VoltageGraphRepositoryImpl(dataSource: sl(), ));

  // usecase
  sl.registerLazySingleton(() => FetchVoltageGraphData(sl()));

  // bloc
  sl.registerFactory(
          () => VoltageGraphBloc(fetchvoltgraphdata: sl()));

  // external
}
