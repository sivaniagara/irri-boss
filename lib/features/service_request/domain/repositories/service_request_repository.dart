import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_request_entity.dart';

abstract class ServiceRequestRepository {
  Future<Either<Failure, List<ServiceRequestEntity>>> getServiceRequests(String userId);
  Future<Either<Failure, void>> updateServiceRequest({
    required String dealerId,
    required String serviceRequestId,
    required String status,
    required String remark,
    required String userId,
    required String controllerId,
    required String sentSms,
  });
}
