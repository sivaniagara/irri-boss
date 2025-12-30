import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/domain/entities/zone_water_fertilizer_entity.dart';

class ZoneSetEntity{
  final String zoneSetName;
  List<ZoneWaterFertilizerEntity> listOfZoneWaterFertilizer;

  ZoneSetEntity({
    required this.zoneSetName,
    required this.listOfZoneWaterFertilizer,
  });

  ZoneSetEntity copyWith({List<ZoneWaterFertilizerEntity>? updatedListOfZoneWaterFertilizer}){
    return ZoneSetEntity(
        zoneSetName: zoneSetName,
        listOfZoneWaterFertilizer: updatedListOfZoneWaterFertilizer ?? listOfZoneWaterFertilizer
    );
  }
}