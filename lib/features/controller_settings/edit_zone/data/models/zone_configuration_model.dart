import '../../domain/entities/zone_nodes_entity.dart';
import 'node_model.dart';

class ZoneConfigurationModel extends ZoneConfigurationEntity {
  ZoneConfigurationModel({
    required super.zoneNumber,
    required super.valves,
    required super.moistureSensors,
    required super.levelSensors,
  });

  factory ZoneConfigurationModel.fromJson(Map<String, dynamic> json) {
    List<NodeModel> parseNodes(List list) {
      return list
          .map<NodeModel>((e) => NodeModel.fromJson(e))
          .toList();
    }

    return ZoneConfigurationModel(
      zoneNumber: json['zoneNumber'] ?? '',
      valves: parseNodes(json['Valves']?[0]['nodeList'] ?? []),
      moistureSensors:
      parseNodes(json['Moisture sensors']?[0]['nodeList'] ?? []),
      levelSensors:
      parseNodes(json['Level sensors']?[0]['nodeList'] ?? []),
    );
  }
}
