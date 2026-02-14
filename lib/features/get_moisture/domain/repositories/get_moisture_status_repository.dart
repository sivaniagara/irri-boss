import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/get_moisture_status_model.dart';

abstract class GetMoistureStatusRepository {
  Future<Either<Failure, GetMoistureStatusModel>> getGetMoistureStatus({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}
