import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/entities/shared_devices_entity.dart';

abstract class SharedDevicesRepository {
  Future<Either<Failure, List<SharedDevicesEntity>>> getSharedDevices(String userId);
}