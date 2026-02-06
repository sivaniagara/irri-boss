import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/exceptions.dart';
import 'package:niagara_smart_drip_irrigation/features/selling_device/data/data_sources/selling_device_remote_datasource.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/selling_device_category_entity.dart';
import '../../domain/entities/selling_unit_entity.dart';
import '../../domain/entities/device_trace_entity.dart';
import '../../domain/repositories/selling_device_repository.dart';

class SellingDeviceRepositoryImpl implements SellingDeviceRepository {
  final SellingDeviceRemoteDataSource remoteDataSource;

  SellingDeviceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<SellingDeviceCategoryEntity>>> getCategoryList() async {
    try {
      final remoteData = await remoteDataSource.getCategoryList();
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<SellingUnitEntity>>> getSellingUnits(String userId, String categoryId) async {
    try {
      final remoteData = await remoteDataSource.getSellingUnits(userId, categoryId);
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, String>>> getUsernameByMobile(String userId, String mobileNumber, String userType) async {
    try {
      final lookupResult = await remoteDataSource.getUsernameByMobile(userId, mobileNumber, userType);
      return Right(lookupResult);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> sellDevices({
    required String userId,
    required String userName,
    required String userType,
    required String mobileCountryCode,
    required String mobileNumber,
    required List<int> productIds,
  }) async {
    try {
      await remoteDataSource.sellDevices(
        userId: userId,
        userName: userName,
        userType: userType,
        mobileCountryCode: mobileCountryCode,
        mobileNumber: mobileNumber,
        productIds: productIds,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, DeviceTraceEntity>> traceDevice(String userId, String deviceId) async {
    try {
      final remoteData = await remoteDataSource.traceDevice(userId, deviceId);
      return Right(remoteData);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addControllerToDealer({required String userId, required int productId}) async {
    try {
      await remoteDataSource.addControllerToDealer(userId: userId, productId: productId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
