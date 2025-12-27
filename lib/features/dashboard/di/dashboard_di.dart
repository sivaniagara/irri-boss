import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/program_preview_dispatcher.dart';

import '../../../core/di/injection.dart';
import '../../../core/services/selected_controller_persistence.dart';
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
}