
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class ControlMotorParams{
  final String userId;
  final String controllerId;
  final String programId;
  final String deviceId;
  final String payload;
  ControlMotorParams({
    required this.userId,
    required this.controllerId,
    required this.programId,
    required this.deviceId,
    required this.payload,
  });
}

class ControlMotorUsecase extends UseCase<Unit, ControlMotorParams>{
  final DashboardRepository repository;
  ControlMotorUsecase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ControlMotorParams params){
    return repository.controlMotor(params);
  }
}