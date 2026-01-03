import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/data/datasources/shared_device_data_source.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/entities/shared_devices_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/repositories/shared_devices_repositories.dart';

class SharedDevicesRepositoryImpl implements SharedDevicesRepository {
  final SharedDevicesDataSource sharedDevicesDataSource;
  SharedDevicesRepositoryImpl({required this.sharedDevicesDataSource});

  @override
  Future<Either<Failure, List<SharedDevicesEntity>>> getSharedDevices(String userId) async {
    try {
      final sharedDevices = await sharedDevicesDataSource.getSharedDevices(userId);
      return Right(sharedDevices);
    } catch(e) {
      return Left(ServerFailure('Shared Devices Fetching Failure: $e'));
    }
  }
}