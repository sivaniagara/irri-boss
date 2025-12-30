import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/data/models/zone_water_fertilizer_model.dart';
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/domain/entities/zone_set_entity.dart';

class ZoneSetModel extends ZoneSetEntity{
  ZoneSetModel({
    required super.zoneSetName,
    required super.listOfZoneWaterFertilizer,
  });

  factory ZoneSetModel.fromJson(Map<String, dynamic> zoneSetData){
    return ZoneSetModel(
        zoneSetName: zoneSetData['zoneSet'],
        listOfZoneWaterFertilizer: zoneSetData['zoneList'].map<ZoneWaterFertilizerModel>((zoneData){
          return ZoneWaterFertilizerModel.fromJson(zoneData: zoneData);
        }).toList()
    );
  }

}