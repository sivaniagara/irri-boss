import '../../domain/entities/program_and_zone_entity.dart';
import '../../domain/entities/zone_entity.dart';
import 'zone_model.dart';

class ProgramAndZoneModel extends ProgramAndZoneEntity {
  ProgramAndZoneModel({
    required super.programId,
    required super.programName,
    required super.zones,
  });

  factory ProgramAndZoneModel.fromJson(Map<String, dynamic> json) {
    return ProgramAndZoneModel(
      programId: json['programId'] ?? 0,
      programName: json['programName'] ?? '',
      zones: (json['zoneList'] as List? ?? [])
          .map<ZoneEntity>((e) => ZoneModel.fromJson(e))
          .toList(),
    );
  }
}
