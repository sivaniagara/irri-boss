import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/common_setting_group_entity.dart';

class ControllerIrrigationSettingEntity{
  final List<CommonSettingGroupEntity> settings;

  const ControllerIrrigationSettingEntity({
    required this.settings,
  });

  ControllerIrrigationSettingEntity copyWith({required List<CommonSettingGroupEntity> updatedSettings}){
    return ControllerIrrigationSettingEntity(
        settings: updatedSettings
    );
  }

}

