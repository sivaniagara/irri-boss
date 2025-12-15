import 'zone_configuration_entity.dart';

class ZoneConfigurationEntity {
  final String zoneNumber;
  final List<NodeEntity> valves;
  final List<NodeEntity> moistureSensors;
  final List<NodeEntity> levelSensors;

  ZoneConfigurationEntity({
    required this.zoneNumber,
    required this.valves,
    required this.moistureSensors,
    required this.levelSensors,
  });
}
