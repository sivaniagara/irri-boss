import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/data/models/common_setting_item_model.dart';

import '../../domain/entities/common_setting_group_entity.dart';
import '../../domain/entities/controller_irrigation_setting_entity.dart';
import 'common_setting_group_model.dart';

class ControllerIrrigationSettingModel extends ControllerIrrigationSettingEntity{
  ControllerIrrigationSettingModel({
    required super.settings,
  });

  factory ControllerIrrigationSettingModel.fromJson({required Map<String, dynamic> json}){
    return ControllerIrrigationSettingModel(
        settings: (json['settings'] as List<dynamic>).map((e) => CommonSettingGroupModel.fromJson(json: e)).toList(),
    );
  }

  factory ControllerIrrigationSettingModel.fromEntity({required ControllerIrrigationSettingEntity entity}){
    return ControllerIrrigationSettingModel(
        settings: entity.settings.map((CommonSettingGroupEntity entity){
          return CommonSettingGroupModel.fromEntity(entity: entity);
        }).toList()
    );
  }

  Map<String, dynamic> toJson(){
    return {
      "settings" : settings.map((groupSetting){
        return (groupSetting as CommonSettingGroupModel).toJson();
      }).toList()
    };
  }

  String getMqttPayload({required int groupIndex, required int settingIndex}){
    final singleOrMultiple = settings[groupIndex].sets[settingIndex];
    if(singleOrMultiple is SingleSettingItemModel){
      return singleOrMultiple.mqttPayload();
    }else{
      String? firstDependent;
      if(
      settings.first.sets.first is SingleSettingItemModel
          &&
          (settings.first.sets.first as SingleSettingItemModel).settingField.contains('PROGSEL')
      ){
        SingleSettingItemModel singleSettingItemModel = settings.first.sets.first as SingleSettingItemModel;
        firstDependent = (singleSettingItemModel.option.indexOf(singleSettingItemModel.value) + 1).toString();
      }
      return (singleOrMultiple as MultipleSettingItemModel).mqttPayload(firstDependent: firstDependent);
    }
  }

}