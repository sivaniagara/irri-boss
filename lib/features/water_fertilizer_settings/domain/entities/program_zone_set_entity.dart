import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/domain/entities/zone_set_entity.dart';

class ProgramZoneSetEntity{
  final String programName;
  final String programId;
  final List<ZoneSetEntity> listOfZoneSet;

  ProgramZoneSetEntity({
    required this.programName,
    required this.programId,
    required this.listOfZoneSet,
  });

  ProgramZoneSetEntity copyWith({List<ZoneSetEntity>? upDatedListOfZoneSet}){
    return ProgramZoneSetEntity(
        programName: programName,
        programId: programId,
        listOfZoneSet: upDatedListOfZoneSet ?? listOfZoneSet
    );
  }


}