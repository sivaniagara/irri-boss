import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../entities/zone_nodes_entity.dart';
import '../repositories/zone_configuration_repository.dart';

class EditZoneConfigurationParams{
  final String userId;
  final String controllerId;
  final String programId;
  final String zoneSerialNo;

  EditZoneConfigurationParams({
    required this.userId,
    required this.controllerId,
    required this.programId,
    required this.zoneSerialNo,
  });
}

class EditZoneConfigurationUseCase extends UseCase<ZoneConfigurationEntity, EditZoneConfigurationParams>{
  final ZoneConfigurationRepository repository;
  EditZoneConfigurationUseCase({required this.repository});

  @override
  Future<Either<Failure, ZoneConfigurationEntity>> call(EditZoneConfigurationParams params)async{
    return repository.editZoneConfiguration(params);
  }
}