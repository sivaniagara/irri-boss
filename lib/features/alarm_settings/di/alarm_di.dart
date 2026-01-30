import 'package:niagara_smart_drip_irrigation/features/alarm_settings/data/data_sources/alarm_remote_source.dart';
import 'package:niagara_smart_drip_irrigation/features/alarm_settings/data/repositories/alarm_repository_impl.dart';
import 'package:niagara_smart_drip_irrigation/features/alarm_settings/domain/repositories/alarm_repository.dart';
import 'package:niagara_smart_drip_irrigation/features/alarm_settings/presentation/bloc/alarm_bloc.dart';
import '../../../core/di/injection.dart';

void initAlarmDependencies() {
  if (!sl.isRegistered<AlarmRemoteSource>()) {
    sl.registerLazySingleton<AlarmRemoteSource>(() => AlarmRemoteSourceImpl(apiClient: sl()));
  }

  if (!sl.isRegistered<AlarmRepository>()) {
    sl.registerLazySingleton<AlarmRepository>(() => AlarmRepositoryImpl(remoteSource: sl()));
  }

  sl.registerFactory(() => AlarmBloc(repository: sl()));
}
