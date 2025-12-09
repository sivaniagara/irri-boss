import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/di/auth.di.dart';
import '../../features/dashboard/di/dashboard_di.dart';
import '../../features/mqtt/bloc/mqtt_bloc.dart';
import '../../features/pump_settings/di/pump_settings_di.dart';
import '../../features/side_drawer/groups/di/groups_di.dart';
import '../../features/side_drawer/sub_users/di/sub_user_di.dart';
import '../flavor/flavor_config.dart';
import '../flavor/flavor_di.dart';
import '../services/api_client.dart';
import '../services/get_credentials.dart';
import '../services/mqtt_service.dart';
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

  /// Register MqttBloc after MqttService
  sl.registerLazySingleton<MqttBloc>(() => MqttBloc(mqttService: sl<MqttService>()));
  /// Flavor-specific services
  registerFlavorDependencies(sl);
  /// Auth Dependencies
  initAuthDependencies();
  /// Dashboard feature
  initDashboardDependencies();

  /// App Drawer
  /// Groups Dependencies
  initGroupDependencies();
  /// Sub Users Dependencies
  initSubUsersDependencies();

  /// Pump Settings Dependencies
  initPumpSettingsDependencies();
}

// Reset all
Future<void> reset() async {
  await sl.reset();
}