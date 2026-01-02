import 'package:niagara_smart_drip_irrigation/features/dashboard/data/datasources/node_status_data_source.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/data/repositories/node_status_repository_impl.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/repositories/node_status_repository.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/usecases/get_node_status_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/presentation/cubit/node_status_cubit.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/program_preview_dispatcher.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/selected_controller_persistence.dart';
import '../presentation/cubit/dashboard_cubit.dart';
import '../utils/dashboard_dispatcher.dart';
import '../dashboard.dart';

void initDashboardDependencies() {
  final persistence = SelectedControllerPersistence();
  persistence.init();
  sl.registerSingleton<SelectedControllerPersistence>(persistence);

  sl.registerLazySingleton<DashboardRemoteDataSource>(() => DashboardRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(remote: sl()));
  sl.registerLazySingleton(() => FetchDashboardGroups(sl()));
  sl.registerLazySingleton(() => FetchControllers(sl()));

  sl.registerLazySingleton<DashboardBloc>(
        () => DashboardBloc(
      fetchDashboardGroups: sl(),
      fetchControllers: sl(),
    ),
  );

  sl.registerLazySingleton<DashboardMessageDispatcher>(() => DashboardMessageDispatcher(dashboardBloc: sl<DashboardBloc>()),);
  sl.registerLazySingleton<ProgramPreviewDispatcher>(() => ProgramPreviewDispatcher());

  sl.registerLazySingleton<NodeStatusDataSource>(() => NodeStatusDataSourceImpl());
  sl.registerLazySingleton<NodeStatusRepository>(() => NodeStatusRepositoryImpl(nodeStatusDataSource: sl()));
  sl.registerLazySingleton(() => GetNodeStatusUsecase(nodeStatusRepository: sl()));
  sl.registerFactory(() => NodeStatusCubit(getNodeStatusUsecase: sl()));
  sl.registerFactory(
        () => DashboardCubit(
      remote: sl<DashboardRemoteDataSource>(),
      dispatcher: sl<DashboardMessageDispatcher>(),
    ),
  );
}