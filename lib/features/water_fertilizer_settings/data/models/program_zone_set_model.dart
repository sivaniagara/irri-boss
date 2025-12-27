import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/data/models/zone_set_model.dart';
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/domain/entities/program_zone_set_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/domain/entities/zone_set_entity.dart';

class ProgramZoneSetModel extends ProgramZoneSetEntity{
  ProgramZoneSetModel({
    required super.programName,
    required super.listOfZoneSet
  });

  factory ProgramZoneSetModel.fromJson({
    required Map<String, dynamic> programData,
    required List<dynamic> listOfZoneSet
  }){
    return ProgramZoneSetModel(
        programName: programData['Name'],
        listOfZoneSet: listOfZoneSet.map<ZoneSetEntity>((zoneSet){
          return ZoneSetModel.fromJson(zoneSet);
        }).toList()
    );
  }

}