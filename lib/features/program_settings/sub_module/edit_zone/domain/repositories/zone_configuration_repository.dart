import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/error/success.dart';
import '../entities/zone_nodes_entity.dart';
import '../usecases/edit_zone_configuration_usecase.dart';
import '../usecases/get_zone_configuration_usecase.dart';
import '../usecases/submit_while_edit_zone_configuration.dart';
import '../usecases/submit_zone_configuration_usecase.dart';

abstract class ZoneConfigurationRepository{
  Future<Either<Failure, ZoneConfigurationEntity>> getZoneConfiguration(GetZoneConfigurationParams params);
  Future<Either<Failure, Unit>> submitZoneConfiguration(SubmitZoneConfigurationParams params);
  Future<Either<Failure, Unit>> submitWhileEditZoneConfiguration(SubmitWhileEditZoneConfigurationParams params);
  Future<Either<Failure, ZoneConfigurationEntity>> editZoneConfiguration(EditZoneConfigurationParams params);
}