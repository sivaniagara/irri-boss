import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/selling_device_category_entity.dart';
import '../entities/selling_unit_entity.dart';
import '../entities/device_trace_entity.dart';

abstract class SellingDeviceRepository {
  Future<Either<Failure, List<SellingDeviceCategoryEntity>>> getCategoryList();
  Future<Either<Failure, List<SellingUnitEntity>>> getSellingUnits(String userId, String categoryId);
  Future<Either<Failure, Map<String, String>>> getUsernameByMobile(String userId, String mobileNumber, String userType);
  Future<Either<Failure, void>> sellDevices({
    required String userId,
    required String userName,
    required String userType,
    required String mobileCountryCode,
    required String mobileNumber,
    required List<int> productIds,
  });
  Future<Either<Failure, DeviceTraceEntity>> traceDevice(String userId, String deviceId);
  Future<Either<Failure, void>> addControllerToDealer({required String userId, required int productId});
}
