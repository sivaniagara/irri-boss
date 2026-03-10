import '../../../core/di/injection.dart';
import '../data/data_source/common_id_settings_remote_source.dart';
import '../data/repositories/common_id_settings_repository_impl.dart';
import '../domain/repositories/common_id_settings_repository.dart';
import '../domain/usecases/get_common_id_settings_usecase.dart';
import '../domain/usecases/reset_common_id_usecase.dart';
import '../domain/usecases/submit_category_usecase.dart';
import '../domain/usecases/view_common_id_usecase.dart';
import '../presentation/bloc/common_id_settings_bloc.dart';

void initCommonSettingDependencies() async{
  /// Common Id Settings Sub Module
  sl.registerFactory(()=> CommonIdSettingsBloc(
    getCommonIdSettingsUsecase: sl(),
    submitCategoryUsecase: sl(),
    resetCommonIdUsecase:sl(),
    viewCommonIdUsecase: sl(),
  ));
  sl.registerLazySingleton(()=> GetCommonIdSettingsUsecase(commonIdSettingsRepository: sl()));
  sl.registerLazySingleton(()=> SubmitCategoryUsecase(commonIdSettingsRepository: sl()));
  sl.registerLazySingleton(()=> ResetCommonIdUsecase(commonIdSettingsRepository: sl()));
  sl.registerLazySingleton(()=> ViewCommonIdUsecase(commonIdSettingsRepository: sl()));
  sl.registerLazySingleton<CommonIdSettingsRepository>(
        () => CommonIdSettingsRepositoryImpl(
      commonIdSettingsDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<CommonIdSettingsRemoteSource>(()=> CommonIdSettingsDataSourceImpl(apiClient: sl(), mqttManager: sl()));

}