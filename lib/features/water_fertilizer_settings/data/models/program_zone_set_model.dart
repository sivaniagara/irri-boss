import 'dart:convert';

import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/data/models/zone_set_model.dart';

import '../../domain/entities/program_zone_set_entity.dart';
import '../../domain/entities/zone_set_entity.dart';
import '../../domain/entities/zone_water_fertilizer_entity.dart';

class ProgramZoneSetModel extends ProgramZoneSetEntity {
  ProgramZoneSetModel({
    required super.programId,
    required super.programName,
    required super.listOfZoneSet,
  });

  // ---------------- COMMAND TEMPLATES ----------------
  static const _zoneTimeSetCommand = 'ZONETIMERSETP:programId:zoneSetId';
  static const _zoneFlowSetCommand = 'FLOWSETP:programId:zoneSetId';
  static const _fertTimeSetCommand = 'FERTTIMERSETP:programIdF:channelNo:zoneSetId';
  static const _fertFlowSetCommand = 'FLOWFERTSETP:programIdF:channelNo:zoneSetId';
  static const _preTimeSetCommand = 'PRETIMERSETP:programId:zoneSetId';
  static const _postTimeSetCommand = 'POSTTIMERSETP:programId:zoneSetId';
  static const _preFlowSetCommand = 'SETPREFLOWP:programId:zoneSetId';
  static const _postFlowSetCommand = 'SETPOSTFLOWP:programId:zoneSetId';

  // ---------------- HELPERS ----------------
  ZoneSetEntity get _zoneSet => listOfZoneSet.first;

  String _cmd(String template, String zoneSetId) =>
      template
          .replaceAll(':programId', programId)
          .replaceAll(':zoneSetId', zoneSetId.padLeft(2, '0'));

  String _joinTimes(Iterable<String> values) =>
      values.map((e) => e.replaceAll(':', '')).join(',');

  String _joinLiters(Iterable<String> values) =>
      values.map((e) => e.padLeft(5, '0')).join(',');

  // ---------------- PAYLOAD BUILDERS ----------------
  String formZonesTimePayload({required String zoneSetId}) =>
      '${_cmd(_zoneTimeSetCommand, zoneSetId)},'
          '${_joinTimes(_zoneSet.listOfZoneWaterFertilizer.map((e) => e.time))}';

  String formPreTimePayload({required String zoneSetId}) =>
      '${_cmd(_preTimeSetCommand, zoneSetId)},'
          '${_joinTimes(_zoneSet.listOfZoneWaterFertilizer.map((e) => e.preTime))}';

  String formPostTimePayload({required String zoneSetId}) =>
      '${_cmd(_postTimeSetCommand, zoneSetId)},'
          '${_joinTimes(_zoneSet.listOfZoneWaterFertilizer.map((e) => e.postTime))}';

  String formZonesFlowPayload({required String zoneSetId}) =>
      '${_cmd(_zoneFlowSetCommand, zoneSetId)},'
          '${_joinLiters(_zoneSet.listOfZoneWaterFertilizer.map((e) => e.liters))}';

  String formPreFlowPayload({required String zoneSetId}) =>
      '${_cmd(_preFlowSetCommand, zoneSetId)},'
          '${_joinLiters(_zoneSet.listOfZoneWaterFertilizer.map((e) => e.preLiters))}';

  String formPostFlowPayload({required String zoneSetId}) =>
      '${_cmd(_postFlowSetCommand, zoneSetId)},'
          '${_joinLiters(_zoneSet.listOfZoneWaterFertilizer.map((e) => e.postLiters))}';

  String formFertTimeFlowPayload({
    required String zoneSetId,
    required int channelNo,
    required int method,
  }) {
    final template =
    method == 1 ? _fertTimeSetCommand : _fertFlowSetCommand;

    final cmd = template
        .replaceAll(':programId', programId)
        .replaceAll(':zoneSetId', zoneSetId.padLeft(2, '0'))
        .replaceAll(':channelNo', channelNo.toString());

    final values = _zoneSet.listOfZoneWaterFertilizer.map(
          (e) => _channelValue(e, channelNo, method),
    );

    return '$cmd,${values.join(',')}';
  }

  String _channelValue(
      ZoneWaterFertilizerEntity e,
      int channelNo,
      int method,
      ) {
    final index = channelNo - 1;

    final times = [
      e.ch1Time,
      e.ch2Time,
      e.ch3Time,
      e.ch4Time,
      e.ch5Time,
      e.ch6Time,
    ];

    final liters = [
      e.ch1Liters,
      e.ch2Liters,
      e.ch3Liters,
      e.ch4Liters,
      e.ch5Liters,
      e.ch6Liters,
    ];

    return method == 1
        ? times[index].replaceAll(':', '')
        : liters[index].padLeft(5, '0');
  }

  // ---------------- ROUTER ----------------
  String mqttPayload({
    required int channelNo,
    required int irrigationDosingOrPrePost,
    required int method,
    required int mode,
    required String zoneSetId,
  }) {
    if (method == 1) {
      if (mode == 1) return formZonesTimePayload(zoneSetId: zoneSetId);
      if (mode == 2) return formPreTimePayload(zoneSetId: zoneSetId);
      if (mode == 3) {
        return formFertTimeFlowPayload(
          zoneSetId: zoneSetId,
          channelNo: channelNo,
          method: method,
        );
      }
      return formPostTimePayload(zoneSetId: zoneSetId);
    }

    if (mode == 1) return formZonesFlowPayload(zoneSetId: zoneSetId);
    if (mode == 2) return formPreFlowPayload(zoneSetId: zoneSetId);
    if (mode == 3) {
      return formFertTimeFlowPayload(
        zoneSetId: zoneSetId,
        channelNo: channelNo,
        method: method,
      );
    }
    return formPostFlowPayload(zoneSetId: zoneSetId);
  }

  // ---------------- FACTORIES ----------------
  factory ProgramZoneSetModel.fromJson({
    required String programId,
    required Map<String, dynamic> programData,
    required List<dynamic> listOfZoneSet,
  }) {
    return ProgramZoneSetModel(
      programId: programId,
      programName: programData['Name'],
      listOfZoneSet:
      listOfZoneSet.map((e) => ZoneSetModel.fromJson(e)).toList(),
    );
  }

  factory ProgramZoneSetModel.fromEntity({
    required ProgramZoneSetEntity entity,
  }) {
    return ProgramZoneSetModel(
      programId: entity.programId,
      programName: entity.programName,
      listOfZoneSet:
      entity.listOfZoneSet.map(ZoneSetModel.fromEntity).toList(),
    );
  }

  int getProgramSettingNo(){
    int progNo = int.parse(programId);
    return (461 + progNo);
  }

  dynamic httpPayload({
    required String programSettingNo,
    required int channelNo,
    required int irrigationDosingOrPrePost,
    required int mode,
    required int method,
    required String zoneSetId,
  }){

    var payload = {
      "receivedData": "",
      "sentSms": mqttPayload(channelNo: channelNo, irrigationDosingOrPrePost: irrigationDosingOrPrePost, method: method, mode: mode, zoneSetId: zoneSetId),
      "menuSettingId": getProgramSettingNo(),
      "sendData": jsonEncode([
        {
          "Name": programName,
          "Fert": "F${channelNo+1}"
        },
        {
          "zoneSet": listOfZoneSet.first.zoneSetName,
          "zoneList" : listOfZoneSet.first.listOfZoneWaterFertilizer.map((e){
            return {
              "zoneNumber": e.zoneNumber,
              "preFlow": e.preLiters,
              "preTime": e.preTime,
              "Time": e.time,
              "Time1": e.ch1Time,
              "Time2": e.ch2Time,
              "Time3": e.ch3Time,
              "Time4": e.ch4Time,
              "Time5": e.ch5Time,
              "Time6": e.ch6Time,
              "Liters": e.liters,
              "Liters1": e.ch1Liters,
              "Liters2": e.ch2Liters,
              "Liters3": e.ch3Liters,
              "Liters4": e.ch4Liters,
              "Liters5": e.ch5Liters,
              "Liters6": e.ch6Liters,
              "postFlow": e.postLiters,
              "postTime": e.postTime
            };
          }).toList(),
        }
      ])
    };
    print("payload === > ${jsonEncode(payload)}");
    return  payload;
  }

}
