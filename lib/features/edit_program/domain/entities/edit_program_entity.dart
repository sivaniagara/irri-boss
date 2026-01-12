import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/entities/zone_setting_entity.dart';

import 'node_entity.dart';

class EditProgramEntity {
  final int programId;
  final String programName;
  final List<ZoneSettingEntity> zones;
  final double timerAdjustPercent;
  final double flowAdjustPercent;
  final double moistureAdjustPercent;
  final double fertilizerAdjustPercent;
  final List<NodeEntity> mappedValves;
  final List<NodeEntity> mappedMoistureSensors;
  final List<NodeEntity> mappedLevelSensors;


  EditProgramEntity({
    required this.programId,
    required this.programName,
    required this.zones,
    required this.timerAdjustPercent,
    required this.flowAdjustPercent,
    required this.moistureAdjustPercent,
    required this.fertilizerAdjustPercent,
    required this.mappedValves,
    required this.mappedMoistureSensors,
    required this.mappedLevelSensors,

  });

  EditProgramEntity copyWith({
    double? updatedTimerAdjustPercent,
    double? updatedFlowAdjustPercent,
    double? updatedMoistureAdjustPercent,
    double? updatedFertilizerAdjustPercent,
    List<ZoneSettingEntity>? updatedZones,
  }){
    return EditProgramEntity(
        programId: programId,
        programName: programName,
        zones: updatedZones ?? zones,
        timerAdjustPercent: updatedTimerAdjustPercent ?? timerAdjustPercent,
        flowAdjustPercent: updatedFlowAdjustPercent ?? flowAdjustPercent,
        moistureAdjustPercent: updatedMoistureAdjustPercent ?? moistureAdjustPercent,
        fertilizerAdjustPercent: updatedFertilizerAdjustPercent ?? fertilizerAdjustPercent,
        mappedValves: mappedValves,
        mappedMoistureSensors: mappedMoistureSensors,
        mappedLevelSensors: mappedLevelSensors,
    );
  }
}

var response = {
  "default" : {
    "valves" : [
      {
        "QRCode": "151091229001",
        "nodeName": "",
        "categoryName": "Valves",
        "nodeId": 5042,
        "userName": "Niagara Solutions",
        "serialNo": "001",
        "categoryId": 2,
        "dateManufacture": "20/09/2021",
        "modelName": "Valve Controller"
      },
      {
        "QRCode": "151091229001",
        "nodeName": "",
        "categoryName": "Valves",
        "nodeId": 5042,
        "userName": "Niagara Solutions",
        "serialNo": "001",
        "categoryId": 2,
        "dateManufacture": "20/09/2021",
        "modelName": "Valve Controller"
      },
    ],
    "moistureSensors" : [
      {
        "QRCode": "151091229001",
        "nodeName": "",
        "categoryName": "Valves",
        "nodeId": 5042,
        "userName": "Niagara Solutions",
        "serialNo": "001",
        "categoryId": 2,
        "dateManufacture": "20/09/2021",
        "modelName": "Valve Controller"
      },
      {
        "QRCode": "151091229001",
        "nodeName": "",
        "categoryName": "Valves",
        "nodeId": 5042,
        "userName": "Niagara Solutions",
        "serialNo": "001",
        "categoryId": 2,
        "dateManufacture": "20/09/2021",
        "modelName": "Valve Controller"
      },
    ],
    "levelSensors" : [
      {
        "QRCode": "151091229001",
        "nodeName": "",
        "categoryName": "Valves",
        "nodeId": 5042,
        "userName": "Niagara Solutions",
        "serialNo": "001",
        "categoryId": 2,
        "dateManufacture": "20/09/2021",
        "modelName": "Valve Controller"
      },
      {
        "QRCode": "151091229001",
        "nodeName": "",
        "categoryName": "Valves",
        "nodeId": 5042,
        "userName": "Niagara Solutions",
        "serialNo": "001",
        "categoryId": 2,
        "dateManufacture": "20/09/2021",
        "modelName": "Valve Controller"
      },
    ],
  },
  "data" : {
    "programId": 1,
    "programName": "Program 1",
    "timerAdjustPercent": 80.0,
    "flowAdjustPercent": 80.0,
    "moistureAdjustPercent": 80.0,
    "fertilizerAdjustPercent": 80.0,
    "zones": [
      {
        "zoneNumber": "ZONE 001",
        "valves": [
          {
            "QRCode": "151091229001",
            "nodeId": 5042,
            "serialNo": "001",
          },
        ],
        "moistureSensor" :[
          {
            "QRCode": "151091229001",
            "nodeId": 5042,
            "serialNo": "001",
          },
        ],
        "levelSensors": [
          {
            "QRCode": "151091229001",
            "nodeId": 5042,
            "serialNo": "001",
          },
        ],
        "time": "00:00",
        "liters": "0",
        "ch1Time": "00:00",
        "ch2Time": "00:00",
        "ch3Time": "00:00",
        "ch4Time": "00:00",
        "ch5Time": "00:00",
        "ch6Time": "00:00",
        "ch1Liters": "0",
        "ch2Liters": "0",
        "ch3Liters": "0",
        "ch4Liters": "0",
        "ch5Liters": "0",
        "ch6Liters": "0",
        "preTime": "00:00",
        "preLiters": "0",
        "postTime": "00:00",
        "postLiters": "0",
      }
    ]

  }
};