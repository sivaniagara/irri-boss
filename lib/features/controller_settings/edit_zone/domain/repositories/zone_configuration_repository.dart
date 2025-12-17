import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/error/success.dart';
import '../entities/zone_nodes_entity.dart';
import '../usecases/get_zone_configuration_usecase.dart';
import '../usecases/submit_zone_configuration_usecase.dart';

abstract class ZoneConfigurationRepository{
  Future<Either<Failure, ZoneConfigurationEntity>> getZoneConfiguration(GetZoneConfigurationParams params);
  Future<Either<Failure, Success>> submitZoneConfiguration(SubmitZoneConfigurationParams params);
}