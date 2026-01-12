import 'node_entity.dart';

class MappedNodeEntity {
  final List<NodeEntity> valves;
  final List<NodeEntity> moistureSensors;
  final List<NodeEntity> levelSensors;

  MappedNodeEntity({
    required this.valves,
    required this.moistureSensors,
    required this.levelSensors,
  });

  MappedNodeEntity copyWith({
    List<NodeEntity>? valves,
    List<NodeEntity>? moistureSensors,
    List<NodeEntity>? levelSensors,
  }) {
    return MappedNodeEntity(
      valves: valves ?? this.valves,
      moistureSensors: moistureSensors ?? this.moistureSensors,
      levelSensors: levelSensors ?? this.levelSensors,
    );
  }
}
