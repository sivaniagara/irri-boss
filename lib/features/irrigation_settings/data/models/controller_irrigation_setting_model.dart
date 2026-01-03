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
}