import 'package:niagara_smart_drip_irrigation/features/edit_program/data/models/node_model.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/entities/mapped_node_entity.dart';

class MappedNodeModel extends MappedNodeEntity {
  MappedNodeModel({
    required super.valves,
    required super.moistureSensors,
    required super.levelSensors,
  });

  factory MappedNodeModel.fromJson(Map<String, dynamic> json, String category) {
    final list = (json[category] as List<dynamic>)
        .map((e) => NodeModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return MappedNodeModel(
      valves: category == 'valves' ? list : [],
      moistureSensors: category == 'moistureSensors' ? list : [],
      levelSensors: category == 'levelSensors' ? list : [],
    );
  }

  // Full from default response
  factory MappedNodeModel.fromDefaultResponse(Map<String, dynamic> defaultMap) {
    return MappedNodeModel(
      valves: (defaultMap['valves'] as List<dynamic>)
          .map((e) => NodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      moistureSensors: (defaultMap['moistureSensors'] as List<dynamic>)
          .map((e) => NodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      levelSensors: (defaultMap['levelSensors'] as List<dynamic>)
          .map((e) => NodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  factory MappedNodeModel.fromEntity(MappedNodeEntity entity) {
    return MappedNodeModel(
      valves: entity.valves.map((e) => NodeModel.fromEntity(e)).toList(),
      moistureSensors: entity.moistureSensors.map((e) => NodeModel.fromEntity(e)).toList(),
      levelSensors: entity.levelSensors.map((e) => NodeModel.fromEntity(e)).toList(),
    );
  }

}