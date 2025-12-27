import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:niagara_smart_drip_irrigation/features/controller_details/data/datasources/controller_datasource.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/program_preview_dispatcher.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/standalone_reports/di/standalone_di.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/tdyvalvestatus_reports/di/tdy_valve_status_di.dart';
import 'package:niagara_smart_drip_irrigation/features/setserialsettings/data/repositories/setserial_details_repositories.dart';
import 'package:niagara_smart_drip_irrigation/features/setserialsettings/domain/usecase/setserial_usercase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/controller_details/data/repositories/controller_details_repositories.dart';
import '../../features/controller_details/domain/repositories/controller_details_repo.dart';
import '../../features/controller_details/domain/usecase/controller_details_usercase.dart';
import '../../features/controller_details/presentation/bloc/controller_details_bloc.dart';
import '../../features/controller_details/presentation/bloc/controller_details_state.dart';
import '../../features/dashboard/utils/dashboard_dispatcher.dart';
import '../../features/dashboard/presentation/cubit/controller_context_cubit.dart';
import '../../features/fault_msg/di/faultmsg_di.dart';
import '../../features/pump_settings/utils/pump_settings_dispatcher.dart';
import '../services/mqtt/app_message_dispatcher.dart';
import '../services/mqtt/mqtt_message_helper.dart';
import '../../features/mapping_and_unmapping_nodes/di/mapping_and_unmapping_node_di.dart';
import '../../features/progam_zone_set/presentation/cubit/program_tab_cubit.dart';
import '../../features/program_settings/di/program_settings_di.dart';
import '../../features/report_downloader/di/report_download_injection.dart';
import '../../features/reports/Motor_cyclic_reports/di/motor_cyclic_di.dart';
import '../../features/reports/Voltage_reports/di/voltage_di.dart';
import '../../features/reports/power_reports/di/power_di.dart';
import '../../features/reports/reportMenu/di/report_di.dart';
import '../../features/reports/zone_duration_reports/di/zone_duration_di.dart';
import '../../features/reports/zonecyclic_reports/di/zone_cyclic_di.dart';
import '../../features/sendrev_msg/di/sendrev_di.dart';
import '../../features/setserialsettings/data/datasources/setserial_datasource.dart';
import '../../features/setserialsettings/domain/repositories/setserial_details_repo.dart';
import '../../features/setserialsettings/domain/usecase/setserial_details_params.dart';
import '../../features/setserialsettings/presentation/bloc/setserial_bloc.dart';
import '../../features/setserialsettings/presentation/bloc/setserial_bloc_event.dart';
import '../../features/auth/di/auth.di.dart';
import '../../features/controller_settings/presentation/cubit/controller_tab_cubit.dart';
import '../../features/dashboard/di/dashboard_di.dart';
import '../../features/pump_settings/di/pump_settings_di.dart';
import '../../features/side_drawer/groups/di/groups_di.dart';
import '../../features/side_drawer/sub_users/di/sub_user_di.dart';
import '../../features/water_fertilizer_settings/di/water_fertilizer_settings_di.dart';
import '../flavor/flavor_config.dart';
import '../flavor/flavor_di.dart';
import '../services/api_client.dart';
import '../services/get_credentials.dart';
import '../services/mqtt/mqtt_manager.dart';
import '../services/mqtt/mqtt_service.dart';
import '../services/network_info.dart';
import '../services/notification_service.dart';
import '../theme/theme_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> init({bool clear = false, SharedPreferences? prefs, http.Client? httpClient}) async {
  if (clear) await reset();

  /// Ensure FlavorConfig was setup
  try {
    final _ = FlavorConfig.instance;
  } catch (e) {
    throw StateError('FlavorConfig must be initialized before DI. Call FlavorConfig.setup(...) in main.');
  }
  /// Core services
  sl.registerLazySingleton(() => ThemeProvider());
  sl.registerSingleton<NotificationService>(NotificationService());
  sl.registerLazySingleton<SomeService>(() => SomeService());

  /// External / third-party
  sl.registerLazySingleton<http.Client>(() => httpClient ?? http.Client());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(baseUrl: FlavorConfig.instance.values.apiBaseUrl, client: sl()));
  final actualPrefs = prefs ?? await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(actualPrefs);
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(Connectivity()));
  sl.registerLazySingleton<MqttService>(
        () => MqttService(
      broker: FlavorConfig.instance.values.broker,
      port: 1883,
      clientIdentifier: 'flutter_client_${DateTime.now().millisecondsSinceEpoch}',
      userName: FlavorConfig.instance.values.userName,
      password: FlavorConfig.instance.values.password,
    ),
  );
  /// Register this for access userId and controllerId for all pages
  sl.registerFactory(() => ControllerContextCubit());
  /// Flavor-specific services
  registerFlavorDependencies(sl);

  initDashboardDependencies();

  sl.registerLazySingleton<AppMessageDispatcher>(
        () => AppMessageDispatcher(
      dashboard: sl<DashboardMessageDispatcher>(),
      pumpSettings: sl<PumpSettingsDispatcher>(),
      programViewDispatcher: sl<ProgramPreviewDispatcher>(),
    ),
  );

  sl.registerLazySingleton<MqttManager>(() => MqttManager(
    mqttService: sl<MqttService>(),
    dispatcher: sl<AppMessageDispatcher>(),
  ));

  /// Auth Dependencies
  initAuthDependencies();

  /// App Drawer
  /// Groups Dependencies
  initGroupDependencies();
  /// Sub Users Dependencies
  initSubUsersDependencies();

  /// Pump Settings Dependencies
  initPumpSettingsDependencies();

  /// controller setting tab Dependencies
  sl.registerFactory(() => ControllerTabCubit());

  /// Program Setting Dependencies
  initProgramSettingDependencies();

  /// Mapping and Unmapping Nodes Dependencies
  initMappingAndUnmappingNodeDependencies();

  /// program tab Dependencies
  sl.registerFactory(() => ProgramTabCubit());

  /// water fertilizer setting dependencies
  initWaterFertilizerSettingsDependencies();

  sl.registerLazySingleton<ControllerRemoteDataSource>(() => ControllerRemoteDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<ControllerRepo>(() => ControllerRepoImpl(remoteDataSource: sl()));
  sl.registerLazySingleton(() => GetControllerDetailsUsecase(controllerRepo: sl()));
  sl.registerFactory(() => ControllerDetailsBloc(getControllerDetails: sl(), updateController: sl(),));
  sl.registerLazySingleton<SetSerialDataSource>(
          () => SetSerialDataSourceImpl(apiClient: sl()));
  sl.registerLazySingleton<SetSerialRepository>(
          () => SetSerialRepositoryImpl(remoteDataSource: sl()));
  sl.registerFactory(() => SetSerialBloc(sl()));
  sl.registerFactory(
          () => SetSerialParams(userId: sl(), controllerId: sl(), type: sl()));
  sl.registerFactory(() => LoadSerialUsecase(sl()));
  sl.registerFactory(() => LoadSerialEvent(userId: sl(), controllerId: sl()));

  initSendRev();
  initfaultmsg();
  initReportDependencies();
  initVoltageGraph();
  initPowerGraph();
  initMotorCyclic();
  initReportDownloadDependencies();
  initZoneDuration();
  initStandalone();
  initTdyValveStatus();
  initZoneCyclic();
}

// Reset all
Future<void> reset() async {
  await sl.reset();
}