import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../entities/controller_irrigation_setting_entity.dart';
import '../repositories/irrigation_settings_repository.dart';

class GetTemplateIrrigationSettingParams{
  final String userId;
  final String controllerId;
  final String subUserId;
  final String settingNo;
  GetTemplateIrrigationSettingParams({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.settingNo,
  });
}


class GetTemplateIrrigationSettingUsecase extends UseCase<ControllerIrrigationSettingEntity, GetTemplateIrrigationSettingParams>{
  final IrrigationSettingsRepository repository;

  GetTemplateIrrigationSettingUsecase({required this.repository});

  @override
  Future<Either<Failure, ControllerIrrigationSettingEntity>>call(GetTemplateIrrigationSettingParams params){
    return repository.getTemplateSetting(params);
  }
}