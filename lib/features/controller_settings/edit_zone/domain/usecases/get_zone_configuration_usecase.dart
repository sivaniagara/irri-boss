import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../entities/zone_nodes_entity.dart';
import '../repositories/zone_configuration_repository.dart';

class GetZoneConfigurationParams {
  final String userId;
  final String controllerId;
  final String programId;
  GetZoneConfigurationParams({required this.userId, required this.controllerId, required this.programId});
}

class GetZoneConfigurationUseCase
    extends UseCase<ZoneConfigurationEntity, GetZoneConfigurationParams> {
  final ZoneConfigurationRepository repository;

  GetZoneConfigurationUseCase({required this.repository});

  @override
  Future<Either<Failure, ZoneConfigurationEntity>> call(
      GetZoneConfigurationParams params) {
    return repository.getZoneConfiguration(params);
  }
}
