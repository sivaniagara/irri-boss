import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/domain/entities/zone_water_fertilizer_entity.dart';

class ZoneWaterFertilizerModel extends ZoneWaterFertilizerEntity{
  ZoneWaterFertilizerModel({
    required super.time,
    required super.liters,
    required super.ch1Time,
    required super.ch2Time,
    required super.ch3Time,
    required super.ch4Time,
    required super.ch5Time,
    required super.ch6Time,
    required super.ch1Liters,
    required super.ch2Liters,
    required super.ch3Liters,
    required super.ch4Liters,
    required super.ch5Liters,
    required super.ch6Liters,
    required super.preTime,
    required super.preLiters,
    required super.postTime,
    required super.postLiters,
  });


  factory ZoneWaterFertilizerModel.fromJson({required Map<String, dynamic> zoneData}){
    return ZoneWaterFertilizerModel(
        time: zoneData['Time'].toString(),
        liters: zoneData['Liters'].toString(),
        ch1Time: zoneData['Time1'].toString(),
        ch2Time: zoneData['Time2'].toString(),
        ch3Time: zoneData['Time3'].toString(),
        ch4Time: zoneData['Time4'].toString(),
        ch5Time: zoneData['Time5'].toString(),
        ch6Time: zoneData['Time6'].toString(),
        ch1Liters: zoneData['Liters1'].toString(),
        ch2Liters: zoneData['Liters2'].toString(),
        ch3Liters: zoneData['Liters3'].toString(),
        ch4Liters: zoneData['Liters4'].toString(),
        ch5Liters: zoneData['Liters5'].toString(),
        ch6Liters: zoneData['Liters6'].toString(),
        preTime: zoneData['preTime'].toString(),
        preLiters: zoneData['preFlow'].toString(),
        postTime: zoneData['postTime'].toString(),
        postLiters: zoneData['postFlow'].toString()
    );
  }

}