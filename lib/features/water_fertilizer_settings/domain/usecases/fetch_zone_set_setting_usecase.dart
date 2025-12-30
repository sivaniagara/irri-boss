import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../entities/program_zone_set_entity.dart';
import '../repositories/water_fertilizer_settings_repository.dart';

class FetchZoneSetSettingParams{
  final String userId;
  final String controllerId;
  final String subUserId;
  final String programId;
  final String programSettingNo;
  final String zoneSetId;
  FetchZoneSetSettingParams({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.programId,
    required this.programSettingNo,
    required this.zoneSetId,
  });
}


class FetchZoneSetSettingUsecase extends UseCase<ProgramZoneSetEntity, FetchZoneSetSettingParams>{
  final WaterFertilizerSettingsRepository repository;
  FetchZoneSetSettingUsecase({required this.repository});

  @override
  Future<Either<Failure, ProgramZoneSetEntity>> call(FetchZoneSetSettingParams params)async{
    return repository.fetchZoneSetSettings(params);
  }
}