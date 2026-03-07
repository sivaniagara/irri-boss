import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/edit_program_repository.dart';

class SendZoneViewCommandParams{
  final String userId;
  final String controllerId;
  final String deviceId;
  final int programId;
  final String zoneNo;
  SendZoneViewCommandParams({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.programId,
    required this.zoneNo,
  });
}


class SendZoneViewCommandUseCase extends UseCase<Unit, SendZoneViewCommandParams>{
  final EditProgramRepository repository;
  SendZoneViewCommandUseCase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(SendZoneViewCommandParams params){
    return repository.sendZoneViewCommandPayload(params);
  }

}