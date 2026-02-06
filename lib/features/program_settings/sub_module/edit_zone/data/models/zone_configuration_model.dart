import '../../domain/entities/zone_nodes_entity.dart';
import 'node_model.dart';

class ZoneConfigurationModel extends ZoneConfigurationEntity{
  // final String zoneNumber;
  // final List<NodeModel> valves;
  // final List<NodeModel> moistureSensors;
  // final List<NodeModel> levelSensors;
  ZoneConfigurationModel({
    required super.zoneNumber,
    required super.valves,
    required super.moistureSensors,
    required super.levelSensors,
  });

  factory ZoneConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ZoneConfigurationModel(
      zoneNumber: json['zoneNumber'] ?? '',
      valves: parseNodes(json['Valves']?[0]['nodeList'] ?? []),
      moistureSensors:
      parseNodes(json['Moisture sensors']?[0]['nodeList'] ?? []),
      levelSensors:
      parseNodes(json['Level sensors']?[0]['nodeList'] ?? []),
    );
  }


  static List<NodeModel> parseNodes(List<dynamic> list, [bool active = false]) {
    return list
        .map<NodeModel>((e) => NodeModel.fromJson(e, active))
        .toList();
  }

  factory ZoneConfigurationModel.fromJsonWhileEdit(Map<String, dynamic> json, String zoneNumber) {

    List<NodeModel>  getMappedAndUnMappedNode(
        {required String nodeName, required Map<String, dynamic> json}){
      List<NodeModel> mappedAndUnMappedNode = [
        ...parseNodes(json['mappedNodes'][nodeName]?[0]['nodeList'], true),
        ...parseNodes(json['unMappedNodes'][nodeName]?[0]['nodeList']),
      ];
      mappedAndUnMappedNode.sort((a, b) {
        final int sa = int.tryParse(a.serialNo) ?? 0;
        final int sb = int.tryParse(b.serialNo) ?? 0;
        return sa.compareTo(sb);
      });
      return mappedAndUnMappedNode;
    }

    return ZoneConfigurationModel(
      zoneNumber: zoneNumber,
      valves: getMappedAndUnMappedNode(nodeName: 'Valves', json : json),
      moistureSensors: getMappedAndUnMappedNode(nodeName: 'Moisture sensors', json : json),
      levelSensors: getMappedAndUnMappedNode(nodeName: 'Level sensors', json : json),
    );
  }

  factory ZoneConfigurationModel.fromEntity(ZoneConfigurationEntity entity) {
    List<NodeModel> parseNodes(List list) {
      return list
          .map<NodeModel>((e) => NodeModel.fromEntity(e))
          .toList();
    }
    return ZoneConfigurationModel(
      zoneNumber: entity.zoneNumber,
      valves: parseNodes(entity.valves),
      moistureSensors: parseNodes(entity.moistureSensors),
      levelSensors: parseNodes(entity.levelSensors),
    );
  }

  // ZoneConfigurationEntity toEntity() {
  //   return ZoneConfigurationEntity(
  //     zoneNumber: zoneNumber,
  //     valves: valves.map((e) => e.toEntity()).toList(),
  //     moistureSensors:
  //     moistureSensors.map((e) => e.toEntity()).toList(),
  //     levelSensors:
  //     levelSensors.map((e) => e.toEntity()).toList(),
  //   );
  // }

  Map<String, dynamic> submitZone({required String programId, bool whileEdit = false}){
    int fixedNodeLength = 4;
    List<String> getBalanceEmptyNode (int count){
      return List.generate(count, (index) => '000');
    }
    List<NodeModel> selectedValves = valves.cast<NodeModel>().where((valve) => valve.select).toList();
    List<NodeModel> selectedMoisture = moistureSensors.cast<NodeModel>().where((valve) => valve.select).toList();
    List<NodeModel> selectedLevel = levelSensors.cast<NodeModel>().where((valve) => valve.select).toList();
    String valveSerialNoInZone = [
      ...selectedValves.map((valve) => valve.serialNo),
      ...getBalanceEmptyNode(fixedNodeLength - selectedValves.length)
    ].join(',');
    String moistureSerialNoInZone = [
      ...selectedMoisture.map((valve) => valve.serialNo),
      ...getBalanceEmptyNode(fixedNodeLength - selectedMoisture.length)
    ].join(',');
    String levelSerialNoInZone = [
      ...selectedLevel.map((valve) => valve.serialNo),
      ...getBalanceEmptyNode(fixedNodeLength - selectedLevel.length)
    ].join(',');
    String rtcAndDaysPayload = '00,00,00,00,0,0,0,0,0,0,0';
    return {
      "moistureSensor" : selectedMoisture.map((e) => {"nodeId" : e.nodeId}).toList(),
      "sensorSms" : "IDZLMSETP$programId$moistureSerialNoInZone,$levelSerialNoInZone",
      "zoneNumber" : zoneNumber.split('ZONE')[1],
      "valves" : selectedValves.map((e) => {"nodeId" : e.nodeId}).toList(),
      "valveSms": "IDZONESELP$programId$valveSerialNoInZone${whileEdit ? rtcAndDaysPayload : ''}",
      "levelSensor": selectedLevel.map((e) => {"nodeId" : e.nodeId}).toList(),
    };
  }
}
