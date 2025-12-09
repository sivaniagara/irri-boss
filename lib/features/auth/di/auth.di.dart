import '../../../core/di/injection.dart';
import '../../../core/services/api_client.dart';
import '../auth.dart';

void initAuthDependencies() {
  // ──────────────────────────────────────
  // 1. Data Sources (Singleton - shared instance)
  // ──────────────────────────────────────
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(prefs: sl(),),);

  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(
      apiClient: sl<ApiClient>(),
    ),);

  // ──────────────────────────────────────
  // 2. Repository (Singleton)
  // ──────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remote: sl(), local: sl(),));

  // ──────────────────────────────────────
  // 3. Use Cases (Factory - new instance every time)
  // ──────────────────────────────────────
  sl.registerFactory(() => LoginWithPassword(sl()));
  sl.registerFactory(() => SendOtp(sl()));
  sl.registerFactory(() => VerifyOtp(sl()));
  sl.registerFactory(() => Logout(sl()));
  sl.registerFactory(() => CheckPhoneNumber(sl()));
  sl.registerFactory(() => SignUp(sl()));
  sl.registerFactory(() => UpdateProfile(sl()));

  // ──────────────────────────────────────
  // 4. Bloc (Factory - BlocProvider auto dispose)
  // ──────────────────────────────────────
  sl.registerFactory(
        () => AuthBloc(
      loginWithPassword: sl(),
      sendOtp: sl(),
      verifyOtp: sl(),
      logout: sl(),
      checkPhoneNumber: sl(),
      signUp: sl(),
      updateProfile: sl(),
    ),
  );
}