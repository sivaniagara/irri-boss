import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/valve_flow_entity.dart';
import '../../../../core/error/failures.dart';
import '../repositories/irrigation_settings_repository.dart';
import 'get_template_irrigation_setting_usecase.dart';

class GetValveFlowSettingUsecase extends UseCase<ValveFlowEntity, GetTemplateIrrigationSettingParams>{
  final IrrigationSettingsRepository repository;

  GetValveFlowSettingUsecase({required this.repository});

  @override
  Future<Either<Failure, ValveFlowEntity>> call(GetTemplateIrrigationSettingParams params){
    return repository.getValveFlowSetting(params);
  }
}