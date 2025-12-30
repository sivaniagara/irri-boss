import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/program_zone_set_entity.dart';
import '../repositories/water_fertilizer_settings_repository.dart';

class UpdateZoneSetSettingParams{
  final String userId;
  final String controllerId;
  final String subUserId;
  final String programId;
  final String programSettingNo;
  final String zoneSetId;
  final int channelNo;
  final int irrigationDosingOrPrePost;
  final int mode;
  final int method;
  final ProgramZoneSetEntity programZoneSetEntity;
  UpdateZoneSetSettingParams({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.programId,
    required this.programSettingNo,
    required this.zoneSetId,
    required this.channelNo,
    required this.irrigationDosingOrPrePost,
    required this.mode,
    required this.method,
    required this.programZoneSetEntity,
  });
}


class UpdateZoneSetSettingUsecase extends UseCase<Unit, UpdateZoneSetSettingParams>{
  final WaterFertilizerSettingsRepository repository;
  UpdateZoneSetSettingUsecase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(UpdateZoneSetSettingParams params)async{
    return repository.updateZoneSetSettings(params);
  }
}