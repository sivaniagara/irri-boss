import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/edit_program_repository.dart';

class SendViewMessageParam{
  final String userId;
  final String controllerId;
  final String programId;
  final String deviceId;
  final String payload;
  SendViewMessageParam({
    required this.userId,
    required this.controllerId,
    required this.programId,
    required this.deviceId,
    required this.payload,
  });
}

class SendViewMessageUsecase extends UseCase<Unit, SendViewMessageParam>{
  final EditProgramRepository repository;
  SendViewMessageUsecase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(SendViewMessageParam params){
    return repository.sendViewMessage(params);
  }
}