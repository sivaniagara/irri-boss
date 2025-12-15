import 'package:niagara_smart_drip_irrigation/features/controller_settings/program_list/domain/entities/zone_entity.dart';

class ProgramAndZoneEntity {
  final int programId;
  final String programName;
  final List<ZoneEntity> zones;

  ProgramAndZoneEntity({
    required this.programId,
    required this.programName,
    required this.zones,
  });
}
