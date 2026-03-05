import 'node_entity.dart';

class MappedNodeEntityProgram {
  final List<NodeEntity> valves;
  final List<NodeEntity> moistureSensors;
  final List<NodeEntity> levelSensors;

  MappedNodeEntityProgram({
    required this.valves,
    required this.moistureSensors,
    required this.levelSensors,
  });

  MappedNodeEntityProgram copyWith({
    List<NodeEntity>? valves,
    List<NodeEntity>? moistureSensors,
    List<NodeEntity>? levelSensors,
  }) {
    return MappedNodeEntityProgram(
      valves: valves ?? this.valves,
      moistureSensors: moistureSensors ?? this.moistureSensors,
      levelSensors: levelSensors ?? this.levelSensors,
    );
  }
}
