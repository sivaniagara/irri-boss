import 'node_entity.dart';

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

  ZoneConfigurationEntity copyWith({
    List<NodeEntity>? valves,
    List<NodeEntity>? moistureSensors,
    List<NodeEntity>? levelSensors,
  }) {
    return ZoneConfigurationEntity(
      zoneNumber: zoneNumber,
      valves: valves ?? this.valves,
      moistureSensors: moistureSensors ?? this.moistureSensors,
      levelSensors: levelSensors ?? this.levelSensors,
    );
  }
}
