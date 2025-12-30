import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import '../entities/program_zone_set_entity.dart';
import '../usecases/fetch_program_zone_sets_usecase.dart';
import '../usecases/fetch_zone_set_setting_usecase.dart';
import '../usecases/update_zone_set_setting_usecase.dart';

abstract class WaterFertilizerSettingsRepository{
  Future<Either<Failure, ProgramZoneSetEntity>> fetchProgramZoneSets(FetchProgramZoneSetsParams params);
  Future<Either<Failure, ProgramZoneSetEntity>> fetchZoneSetSettings(FetchZoneSetSettingParams params);
  Future<Either<Failure, Unit>> updateZoneSetSettings(UpdateZoneSetSettingParams params);
}