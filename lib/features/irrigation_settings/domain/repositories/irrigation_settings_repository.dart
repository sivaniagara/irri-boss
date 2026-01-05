import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import '../entities/controller_irrigation_setting_entity.dart';
import '../entities/valve_flow_entity.dart';
import '../usecases/get_template_irrigation_setting_usecase.dart';

abstract class IrrigationSettingsRepository{
  Future<Either<Failure, ControllerIrrigationSettingEntity>> getTemplateSetting(GetTemplateIrrigationSettingParams params);
  Future<Either<Failure, ValveFlowEntity>> getValveFlowSetting(GetTemplateIrrigationSettingParams params);
  Future<Either<Failure, void>> publishValveFlowSms({
    required String userId,
    required String controllerId,
    required String subUserId,
    required String sentSms,
  });
  Future<Either<Failure, void>> saveValveFlowSettings({
    required String userId,
    required String controllerId,
    required String subUserId,
    required ValveFlowEntity entity,
  });
}