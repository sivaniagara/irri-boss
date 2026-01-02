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
}