import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/data/datasources/shared_device_data_source.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/data/repositories/shared_devices_repository_impl.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/repositories/shared_devices_repositories.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/usecases/get_shared_device_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/presentation/cubit/shared_devices_cubit.dart';

import '../../../../core/di/injection.dart';

void initSharedDevicesDependencies() {
  sl.registerLazySingleton<SharedDevicesDataSource>(() => SharedDeviceDataSourceImpl());
  sl.registerLazySingleton<SharedDevicesRepository>(() => SharedDevicesRepositoryImpl(sharedDevicesDataSource: sl()));

  sl.registerFactory(() => GetSharedDevicesUsecase(repository: sl()));

  sl.registerLazySingleton(() => SharedDevicesCubit(getSharedDevicesUsecase: sl()));
}