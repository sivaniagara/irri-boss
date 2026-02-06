import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../entities/zone_setting_entity.dart';
import '../repositories/edit_program_repository.dart';

class SendZoneConfigurationParams{
  final String userId;
  final String controllerId;
  final String deviceId;
  final int programId;
  final ZoneSettingEntity zoneSettingEntity;
  SendZoneConfigurationParams({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.programId,
    required this.zoneSettingEntity,
  });
}


class SendZoneConfigurationPayloadUsecase extends UseCase<Unit, SendZoneConfigurationParams>{
  final EditProgramRepository repository;
  SendZoneConfigurationPayloadUsecase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(SendZoneConfigurationParams params){
    return repository.sendZoneConfigurationPayload(params);
  }

}