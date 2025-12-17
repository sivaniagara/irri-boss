import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../../../../../core/error/success.dart';
import '../entities/zone_nodes_entity.dart';
import '../repositories/zone_configuration_repository.dart';

class SubmitZoneConfigurationParams{
  final String userId;
  final String controllerId;
  final ZoneConfigurationEntity zoneNodes;

  SubmitZoneConfigurationParams({
    required this.userId,
    required this.controllerId,
    required this.zoneNodes,
  });
}

class SubmitZoneConfigurationUsecase extends UseCase<Success, SubmitZoneConfigurationParams>{
  final ZoneConfigurationRepository zoneConfigurationRepository;
  SubmitZoneConfigurationUsecase({required this.zoneConfigurationRepository});

  @override
  Future<Either<Failure, Success>> call(SubmitZoneConfigurationParams params) async{
    return zoneConfigurationRepository.submitZoneConfiguration(params);
  }
}
