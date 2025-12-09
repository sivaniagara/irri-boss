import '../../../../core/di/injection.dart';
import '../groups_barrel.dart';

void initGroupDependencies() {
  sl.registerLazySingleton<GroupDataSources>(() => GroupDataSourcesImpl(apiClient: sl()));
  sl.registerLazySingleton<GroupRepository>(() => GroupRepositoryImpl(groupDataSources: sl()));
  sl.registerLazySingleton(() => GroupFetchingUsecase(sl()));
  sl.registerLazySingleton(() => GroupAddingUsecase(sl()));
  sl.registerLazySingleton(() => EditGroupUsecase(sl()));
  sl.registerLazySingleton(() => DeleteGroupUsecase(sl()));
  sl.registerLazySingleton(() => GroupBloc(
      groupFetchingUsecase: sl(),
      groupAddingUsecase: sl(),
      editGroupUsecase: sl(),
      deleteGroupUsecase: sl()
  ));
}