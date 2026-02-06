import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/entities/selected_node_entity.dart';

class ZoneSettingEntity{
  final String zoneNumber;
  final List<SelectedNodeEntity> valves;
  final List<SelectedNodeEntity> moistureSensors;
  final List<SelectedNodeEntity> levelSensors;
  String time;
  String liters;
  String ch1Time;
  String ch2Time;
  String ch3Time;
  String ch4Time;
  String ch5Time;
  String ch6Time;
  String ch1Liters;
  String ch2Liters;
  String ch3Liters;
  String ch4Liters;
  String ch5Liters;
  String ch6Liters;
  String preTime;
  String preLiters;
  String postTime;
  String postLiters;
  final bool active;

  ZoneSettingEntity({
    required this.valves,
    required this.moistureSensors,
    required this.levelSensors,
    required this.zoneNumber,
    required this.time,
    required this.liters,
    required this.ch1Time,
    required this.ch2Time,
    required this.ch3Time,
    required this.ch4Time,
    required this.ch5Time,
    required this.ch6Time,
    required this.ch1Liters,
    required this.ch2Liters,
    required this.ch3Liters,
    required this.ch4Liters,
    required this.ch5Liters,
    required this.ch6Liters,
    required this.preTime,
    required this.preLiters,
    required this.postTime,
    required this.postLiters,
    this.active = true
  });

  factory ZoneSettingEntity.defaultZone(String zoneNumber){
    return ZoneSettingEntity(
        valves: [],
        moistureSensors: [],
        levelSensors: [],
        zoneNumber: zoneNumber,
        time: '00:00',
        liters: '0',
        ch1Time: '00:00',
        ch2Time: '00:00',
        ch3Time: '00:00',
        ch4Time: '00:00',
        ch5Time: '00:00',
        ch6Time: '00:00',
        ch1Liters: '0',
        ch2Liters: '0',
        ch3Liters: '0',
        ch4Liters: '0',
        ch5Liters: '0',
        ch6Liters: '0',
        preTime: '00:00',
        preLiters: '0',
        postTime: '00:00',
        postLiters: '0'
    );
  }


  ZoneSettingEntity copyWith({
    List<SelectedNodeEntity>? updatedValves,
    List<SelectedNodeEntity>? updatedMoistureSensors,
    List<SelectedNodeEntity>? updatedLevelSensors,
    String? updatedTime,
    String? updatedLiters,
    String? updatedCh1Time,
    String? updatedCh2Time,
    String? updatedCh3Time,
    String? updatedCh4Time,
    String? updatedCh5Time,
    String? updatedCh6Time,
    String? updatedCh1Liters,
    String? updatedCh2Liters,
    String? updatedCh3Liters,
    String? updatedCh4Liters,
    String? updatedCh5Liters,
    String? updatedCh6Liters,
    String? updatedPreTime,
    String? updatedPreLiters,
    String? updatedPostTime,
    String? updatedPostLiters,
    bool? isActive,
  }){
    print('updatedCh1Liters : ${updatedCh1Liters}');
    return ZoneSettingEntity(
        valves: updatedValves ?? valves,
        moistureSensors: updatedMoistureSensors ?? moistureSensors,
        levelSensors: updatedLevelSensors ?? levelSensors,
        zoneNumber: zoneNumber,
        time: updatedTime ?? time,
        liters: updatedLiters ?? liters,
        ch1Time: updatedCh1Time ?? ch1Time,
        ch2Time: updatedCh2Time ?? ch2Time,
        ch3Time: updatedCh3Time ?? ch3Time,
        ch4Time: updatedCh4Time ?? ch4Time,
        ch5Time: updatedCh5Time ?? ch5Time,
        ch6Time: updatedCh6Time ?? ch6Time,
        ch1Liters: updatedCh1Liters ?? ch1Liters,
        ch2Liters: updatedCh2Liters ?? ch2Liters,
        ch3Liters: updatedCh3Liters ?? ch3Liters,
        ch4Liters: updatedCh4Liters ?? ch4Liters,
        ch5Liters: updatedCh5Liters ?? ch5Liters,
        ch6Liters: updatedCh6Liters ?? ch6Liters,
        preTime: updatedPreTime ?? preTime,
        preLiters: updatedPreLiters ?? preLiters,
        postTime: updatedPostTime ?? postTime,
        postLiters: updatedPostLiters ?? postLiters,
        active: isActive ?? active
    );
  }
}