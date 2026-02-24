import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/get_moisture_status_model.dart';
import '../repositories/get_moisture_status_repository.dart';

class GetMoistureStatus {
  final GetMoistureStatusRepository repository;

  GetMoistureStatus(this.repository);

  Future<Either<Failure, GetMoistureStatusModel>> call({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) async {
    return await repository.getGetMoistureStatus(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
