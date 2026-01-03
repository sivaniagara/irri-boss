import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/common_setting_group_entity.dart';

import '../../domain/entities/common_setting_item_entity.dart';
import 'common_setting_item_model.dart';

class CommonSettingGroupModel extends CommonSettingGroupEntity{
  CommonSettingGroupModel({
    required super.tid,
    required super.name,
    required super.sets
  });

  factory CommonSettingGroupModel.fromJson(
      {required Map<String, dynamic> json}){
    return CommonSettingGroupModel(
        tid: json['TID'],
        name: json['NAME'],
        sets: json['SETS'].map<CommonSettingItemEntity>((e){
          if(!e['VAL'].contains(';')){
            return SingleSettingItemModel.fromJson(json: e);
          }else{
            return MultipleSettingItemModel.fromJson(json: e);
          }
        }).toList()
    );
  }

  factory CommonSettingGroupModel.fromEntity(
      {required CommonSettingGroupEntity entity}){
    return CommonSettingGroupModel(
        tid: entity.tid,
        name: entity.name,
        sets: entity.sets.map((setting){
          if(setting is SingleSettingItemEntity){
            return SingleSettingItemModel.fromEntity(entity: setting);
          }else{
            return MultipleSettingItemModel.fromEntity(entity: setting as MultipleSettingItemEntity);
          }
        }).toList()
    );
  }

  Map<String,dynamic> toJson(){
    return {
      'TID': tid,
      'NAME': name,
      'SETS': sets.map((setting){
        print(setting);
        if(setting is SingleSettingItemModel){
          return setting.toJson();
        }else{
          return (setting as MultipleSettingItemModel).toJson();
        }

      }).toList(),
    };
  }

}