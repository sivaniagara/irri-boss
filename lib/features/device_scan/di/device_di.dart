import '../../../core/di/injection.dart';
import '../data/datasource/device_api.dart';
import '../data/repository/device_repository.dart';
import '../bloc/device_bloc.dart';

void initDeviceScan() {
  // datasource
  sl.registerLazySingleton<DeviceApi>(() => DeviceApi(sl()));

  // repository
  sl.registerLazySingleton<DeviceRepository>(() => DeviceRepository(sl()));

  // bloc
  sl.registerFactory(() => QRDeviceBloc(sl()));
}
