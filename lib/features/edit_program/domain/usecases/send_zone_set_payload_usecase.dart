
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/edit_program_entity.dart';
import '../repositories/edit_program_repository.dart';

class SendZoneSetPayloadParams{
  final String userId;
  final String controllerId;
  final String deviceId;
  final int programId;
  final int zoneSetNo;
  final EditProgramEntity editProgramEntity;
  final int channelNo;
  final int irrigationDosingOrPrePost;
  final int method;
  SendZoneSetPayloadParams({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.programId,
    required this.zoneSetNo,
    required this.editProgramEntity,
    required this.channelNo,
    required this.irrigationDosingOrPrePost,
    required this.method,
  });
}

class SendZoneSetPayloadUsecase extends UseCase<Unit, SendZoneSetPayloadParams>{
  final EditProgramRepository repository;
  SendZoneSetPayloadUsecase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(SendZoneSetPayloadParams params){
    return repository.sendZoneSetPayload(params);
  }

}