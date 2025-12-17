import '../../domain/entities/zone_nodes_entity.dart';
import 'node_model.dart';

class ZoneConfigurationModel{
  final String zoneNumber;
  final List<NodeModel> valves;
  final List<NodeModel> moistureSensors;
  final List<NodeModel> levelSensors;
  ZoneConfigurationModel({
    required this.zoneNumber,
    required this.valves,
    required this.moistureSensors,
    required this.levelSensors,
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

  factory ZoneConfigurationModel.fromEntity(ZoneConfigurationEntity entity) {
    List<NodeModel> parseNodes(List list) {
      return list
          .map<NodeModel>((e) => NodeModel.fromJson(e))
          .toList();
    }
    return ZoneConfigurationModel(
      zoneNumber: entity.zoneNumber,
      valves: parseNodes(entity.valves),
      moistureSensors: parseNodes(entity.moistureSensors),
      levelSensors: parseNodes(entity.levelSensors),
    );
  }

  ZoneConfigurationEntity toEntity() {
    return ZoneConfigurationEntity(
      zoneNumber: zoneNumber,
      valves: valves.map((e) => e.toEntity()).toList(),
      moistureSensors:
      moistureSensors.map((e) => e.toEntity()).toList(),
      levelSensors:
      levelSensors.map((e) => e.toEntity()).toList(),
    );
  }

  Map<String, dynamic> submitZone({required String programId}){
    List<NodeModel> selectedValves = valves.where((valve) => valve.select).toList();
    List<NodeModel> selectedMoisture = moistureSensors.where((valve) => valve.select).toList();
    List<NodeModel> selectedLevel = levelSensors.where((valve) => valve.select).toList();
    String valveSerialNoInZone = selectedValves.map((valve) => valve.serialNo).join(',');
    String moistureSerialNoInZone = selectedMoisture.map((valve) => valve.serialNo).join(',');
    String levelSerialNoInZone = selectedLevel.map((valve) => valve.serialNo).join(',');
    return {
      "moistureSensor" : moistureSensors.map((e) => {"nodeId" : e.nodeId}).toList(),
      "sensorSms" : "IDZLMSETP$programId$moistureSerialNoInZone,$levelSerialNoInZone",
      "zoneNumber" : zoneNumber.split('ZONE')[1],
      "valves" : valves.map((e) => {"nodeId" : e.nodeId}).toList(),
      "valveSms": "IDZONESELP$programId$valveSerialNoInZone",
      "levelSensor": levelSensors.map((e) => {"nodeId" : e.nodeId}).toList(),
    };
  }
}
