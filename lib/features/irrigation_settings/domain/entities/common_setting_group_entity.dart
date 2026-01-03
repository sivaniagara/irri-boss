import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/setting_item_entity.dart';

import 'common_setting_item_entity.dart';

class CommonSettingGroupEntity {
  final int tid;
  final String name;
  List<CommonSettingItemEntity> sets;

  CommonSettingGroupEntity({
    required this.tid,
    required this.name,
    required this.sets,
  });

  CommonSettingGroupEntity copyWith({required List<CommonSettingItemEntity> updatedSets}){
    return CommonSettingGroupEntity(
        tid: tid,
        name: name,
        sets: updatedSets
    );
  }

}
