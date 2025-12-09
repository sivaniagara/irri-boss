import '../../../core/di/injection.dart';
import '../../../core/services/selected_controller_persistence.dart';
import '../../mqtt/utils/mqtt_message_helper.dart';
import '../utils/dashboard_dispatcher.dart';
import '../dashboard.dart';

void initDashboardDependencies() async{

  final persistence = SelectedControllerPersistence();
  await persistence.init();
  sl.registerSingleton<SelectedControllerPersistence>(persistence);

  sl.registerLazySingleton<DashboardRemoteDataSource>(() => DashboardRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<DashboardRepository>(() => DashboardRepositoryImpl(remote: sl()));
  sl.registerLazySingleton(() => FetchDashboardGroups(sl()));
  sl.registerLazySingleton(() => FetchControllers(sl()));
  sl.registerLazySingleton(() => DashboardBloc(fetchDashboardGroups: sl(), fetchControllers: sl(), mqttBloc: sl()));

  sl.registerLazySingleton<MessageDispatcher>(() => DashboardMessageDispatcher(dashboardBloc: sl<DashboardBloc>()));
}