import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../../../../../core/error/success.dart';
import '../entities/zone_nodes_entity.dart';
import '../repositories/zone_configuration_repository.dart';

class SubmitZoneConfigurationParams{
  final String userId;
  final String controllerId;
  final String programId;
  final ZoneConfigurationEntity zoneNodes;

  SubmitZoneConfigurationParams({
    required this.userId,
    required this.controllerId,
    required this.programId,
    required this.zoneNodes,
  });
}

class SubmitZoneConfigurationUsecase extends UseCase<Unit, SubmitZoneConfigurationParams>{
  final ZoneConfigurationRepository repository;
  SubmitZoneConfigurationUsecase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(SubmitZoneConfigurationParams params) async{
    print('SubmitZoneConfigurationUsecase called.....');
    return repository.submitZoneConfiguration(params);
  }
}
