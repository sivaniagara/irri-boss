import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../repositories/dashboard_repository.dart';

class UpdateChangeFromParam{
  final String userId;
  final String controllerId;
  final String programId;
  final String deviceId;
  final String payload;
  UpdateChangeFromParam({
    required this.userId,
    required this.controllerId,
    required this.programId,
    required this.deviceId,
    required this.payload,
  });
}

class UpdateChangeFromUsecase extends UseCase<Unit, UpdateChangeFromParam>{
  final DashboardRepository repository;
  UpdateChangeFromUsecase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(UpdateChangeFromParam params){
    return repository.updateChangeFrom(params);
  }
}