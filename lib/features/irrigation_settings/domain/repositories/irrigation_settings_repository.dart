import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';

import '../entities/controller_irrigation_setting_entity.dart';
import '../usecases/get_template_irrigation_setting_usecase.dart';

abstract class IrrigationSettingsRepository{
  Future<Either<Failure, ControllerIrrigationSettingEntity>> getTemplateSetting(GetTemplateIrrigationSettingParams params);
}