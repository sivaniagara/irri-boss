import 'package:niagara_smart_drip_irrigation/features/edit_program/data/models/selected_node_model.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/entities/zone_setting_entity.dart';

class ZoneSettingModel extends ZoneSettingEntity {
  ZoneSettingModel({
    required super.zoneNumber,
    required super.valves,
    required super.moistureSensors,
    required super.levelSensors,
    required super.time,
    required super.liters,
    required super.ch1Time,
    required super.ch2Time,
    required super.ch3Time,
    required super.ch4Time,
    required super.ch5Time,
    required super.ch6Time,
    required super.ch1Liters,
    required super.ch2Liters,
    required super.ch3Liters,
    required super.ch4Liters,
    required super.ch5Liters,
    required super.ch6Liters,
    required super.preTime,
    required super.preLiters,
    required super.postTime,
    required super.postLiters,
  });

  factory ZoneSettingModel.fromJson(Map<String, dynamic> json) {
    return ZoneSettingModel(
      zoneNumber: json['zoneNumber'] as String,
      valves: (json['valves'] as List<dynamic>)
          .map((e) => SelectedNodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      moistureSensors: (json['moistureSensor'] as List<dynamic>? ?? [])
          .map((e) => SelectedNodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      levelSensors: (json['levelSensors'] as List<dynamic>? ?? [])
          .map((e) => SelectedNodeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      time: json['time'] as String,
      liters: json['liters'] as String,
      ch1Time: json['ch1Time'] as String,
      ch2Time: json['ch2Time'] as String,
      ch3Time: json['ch3Time'] as String,
      ch4Time: json['ch4Time'] as String,
      ch5Time: json['ch5Time'] as String,
      ch6Time: json['ch6Time'] as String,
      ch1Liters: json['ch1Liters'] as String,
      ch2Liters: json['ch2Liters'] as String,
      ch3Liters: json['ch3Liters'] as String,
      ch4Liters: json['ch4Liters'] as String,
      ch5Liters: json['ch5Liters'] as String,
      ch6Liters: json['ch6Liters'] as String,
      preTime: json['preTime'] as String,
      preLiters: json['preLiters'] as String,
      postTime: json['postTime'] as String,
      postLiters: json['postLiters'] as String,
    );
  }

  factory ZoneSettingModel.fromEntity(ZoneSettingEntity entity) {
    return ZoneSettingModel(
      zoneNumber: entity.zoneNumber,
      valves: entity.valves.map((e) => SelectedNodeModel.fromEntity(e)).toList(),
      moistureSensors: entity.moistureSensors.map((e) => SelectedNodeModel.fromEntity(e)).toList(),
      levelSensors: entity.levelSensors.map((e) => SelectedNodeModel.fromEntity(e)).toList(),
      time: entity.time,
      liters: entity.liters,
      ch1Time: entity.ch1Time,
      ch2Time: entity.ch2Time,
      ch3Time: entity.ch3Time,
      ch4Time: entity.ch4Time,
      ch5Time: entity.ch5Time,
      ch6Time: entity.ch6Time,
      ch1Liters: entity.ch1Liters,
      ch2Liters: entity.ch2Liters,
      ch3Liters: entity.ch3Liters,
      ch4Liters: entity.ch4Liters,
      ch5Liters: entity.ch5Liters,
      ch6Liters: entity.ch6Liters,
      preTime: entity.preTime,
      preLiters: entity.preLiters,
      postTime: entity.postTime,
      postLiters: entity.postLiters,
    );
  }

  ZoneSettingEntity toEntity() {
    return ZoneSettingEntity(
      zoneNumber: zoneNumber,
      valves: valves,
      moistureSensors: moistureSensors,
      levelSensors: levelSensors,
      time: time,
      liters: liters,
      ch1Time: ch1Time,
      ch2Time: ch2Time,
      ch3Time: ch3Time,
      ch4Time: ch4Time,
      ch5Time: ch5Time,
      ch6Time: ch6Time,
      ch1Liters: ch1Liters,
      ch2Liters: ch2Liters,
      ch3Liters: ch3Liters,
      ch4Liters: ch4Liters,
      ch5Liters: ch5Liters,
      ch6Liters: ch6Liters,
      preTime: preTime,
      preLiters: preLiters,
      postTime: postTime,
      postLiters: postLiters,
    );
  }

  List<String> submitZone({required int programId}){
    int fixedNodeLength = 4;
    List<String> getBalanceEmptyNode (int count){
      return List.generate(count, (index) => '000');
    }
    List<String> selectedValves = valves.map((valve) => valve.serialNo).toList();
    List<String> selectedMoisture = moistureSensors.map((valve) => valve.serialNo).toList();
    List<String> selectedLevel = levelSensors.map((valve) => valve.serialNo).toList();
    String valveSerialNoInZone = [
      ...selectedValves,
      ...getBalanceEmptyNode(fixedNodeLength - selectedValves.length)
    ].join(',');
    String moistureSerialNoInZone = [
      ...selectedMoisture,
      ...getBalanceEmptyNode(fixedNodeLength - selectedMoisture.length)
    ].join(',');
    String levelSerialNoInZone = [
      ...selectedLevel,
      ...getBalanceEmptyNode(fixedNodeLength - selectedLevel.length)
    ].join(',');
    return [
      "IDZONESELP$programId$zoneNumber,$valveSerialNoInZone",
      "IDZLMSETP$programId$moistureSerialNoInZone,$levelSerialNoInZone"
    ];
  }
}