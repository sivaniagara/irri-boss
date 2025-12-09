import 'package:logger/logger.dart';

import '../../../../core/di/injection.dart';
import '../sub_users_barrel.dart';

void initSubUsersDependencies() {
  sl.registerLazySingleton<SubUserDataSources>(() => SubUserDataSourceImpl(apiClient: sl(), logger: Logger()));
  sl.registerLazySingleton<SubUserRepo>(() => SubUserRepositoryImpl(subUserDataSources: sl()));
  sl.registerLazySingleton(() => GetSubUsersUsecase(subUserRepo: sl()));
  sl.registerLazySingleton(() => GetSubUserDetailsUsecase(subUserRepo: sl()));
  sl.registerLazySingleton(() => UpdateSubUserDetailsUseCase(subUserRepo: sl()));
  sl.registerFactory(() => GetSubUserByPhoneUsecase(subUserRepo: sl()));
  sl.registerFactory(() => SubUsersBloc(
    getSubUsersUsecase: sl(),
    getSubUserDetailsUsecase: sl(),
    updateSubUserDetailsUseCase: sl(),
    getSubUserByPhoneUsecase: sl(),
  ));
}