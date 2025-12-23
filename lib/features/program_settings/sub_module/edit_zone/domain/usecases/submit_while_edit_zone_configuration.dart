import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../../../../../../core/error/success.dart';
import '../entities/zone_nodes_entity.dart';
import '../repositories/zone_configuration_repository.dart';

class SubmitWhileEditZoneConfigurationParams{
  final String userId;
  final String controllerId;
  final String programId;
  final ZoneConfigurationEntity zoneNodes;

  SubmitWhileEditZoneConfigurationParams({
    required this.userId,
    required this.controllerId,
    required this.programId,
    required this.zoneNodes,
  });
}

class SubmitWhileEditZoneConfigurationUseCase extends UseCase<Unit, SubmitWhileEditZoneConfigurationParams>{
  final ZoneConfigurationRepository repository;
  SubmitWhileEditZoneConfigurationUseCase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(SubmitWhileEditZoneConfigurationParams params) async{
    print('SubmitWhileEditZoneConfigurationUsecase called.....');
    return repository.submitWhileEditZoneConfiguration(params);
  }
}
