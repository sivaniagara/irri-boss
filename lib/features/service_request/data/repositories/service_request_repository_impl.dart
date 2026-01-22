import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/service_request_entity.dart';
import '../../domain/repositories/service_request_repository.dart';
import '../datasources/service_request_remote_datasource.dart';

class ServiceRequestRepositoryImpl implements ServiceRequestRepository {
  final ServiceRequestRemoteDataSource remoteDataSource;

  ServiceRequestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ServiceRequestEntity>>> getServiceRequests(String userId) async {
    try {
      final remoteData = await remoteDataSource.getServiceRequests(userId);
      return Right(remoteData);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateServiceRequest({
    required String dealerId,
    required String serviceRequestId,
    required String status,
    required String remark,
    required String userId,
    required String controllerId,
    required String sentSms,
  }) async {
    try {
      await remoteDataSource.updateServiceRequest(
        dealerId: dealerId,
        serviceRequestId: serviceRequestId,
        status: status,
        remark: remark,
        userId: userId,
        controllerId: controllerId,
        sentSms: sentSms,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
