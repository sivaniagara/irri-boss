import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../entities/controller_irrigation_setting_entity.dart';
import '../repositories/irrigation_settings_repository.dart';

class UpdateTemplateIrrigationSettingParams{
  final String userId;
  final String controllerId;
  final String deviceId;
  final String subUserId;
  final String settingNo;
  final ControllerIrrigationSettingEntity controllerIrrigationSettingEntity;
  final int groupIndex;
  final int settingIndex;
  UpdateTemplateIrrigationSettingParams({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.subUserId,
    required this.settingNo,
    required this.controllerIrrigationSettingEntity,
    required this.groupIndex,
    required this.settingIndex,
  });
}


class UpdateTemplateIrrigationSettingUsecase extends UseCase<Unit, UpdateTemplateIrrigationSettingParams>{
  final IrrigationSettingsRepository repository;

  UpdateTemplateIrrigationSettingUsecase({required this.repository});

  @override
  Future<Either<Failure, Unit>>call(UpdateTemplateIrrigationSettingParams params){
    return repository.updateTemplateSetting(params);
  }
}