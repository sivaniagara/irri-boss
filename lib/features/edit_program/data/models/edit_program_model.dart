import 'package:niagara_smart_drip_irrigation/features/edit_program/data/models/zone_setting_model.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/data/models/mapped_node_model.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/entities/edit_program_entity.dart';

import '../../domain/entities/zone_setting_entity.dart';
import 'node_model.dart';

class EditProgramModel extends EditProgramEntity {
  EditProgramModel({
    required super.programId,
    required super.programName,
    required super.zones,
    required super.timerAdjustPercent,
    required super.flowAdjustPercent,
    required super.moistureAdjustPercent,
    required super.fertilizerAdjustPercent,
    required super.mappedValves,
    required super.mappedMoistureSensors,
    required super.mappedLevelSensors,
  });

  factory EditProgramModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final defaultData = json['default'] as Map<String, dynamic>;

    return EditProgramModel(
      programId: data['programId'] as int,
      programName: data['programName'] as String,
      timerAdjustPercent: (data['timerAdjustPercent'] as num).toDouble(),
      flowAdjustPercent: (data['flowAdjustPercent'] as num).toDouble(),
      moistureAdjustPercent: (data['moistureAdjustPercent'] as num).toDouble(),
      fertilizerAdjustPercent: (data['fertilizerAdjustPercent'] as num).toDouble(),
      zones: (data['zones'] as List<dynamic>)
          .map((e) => ZoneSettingModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      mappedValves: (defaultData['valves'] as List<dynamic>).map((e) => NodeModel.fromJson(e)).toList(),
      mappedMoistureSensors: (defaultData['moistureSensors'] as List<dynamic>).map((e) => NodeModel.fromJson(e)).toList(),
      mappedLevelSensors: (defaultData['levelSensors'] as List<dynamic>).map((e) => NodeModel.fromJson(e)).toList(),
    );
  }

  factory EditProgramModel.fromEntity(EditProgramEntity entity) {
    return EditProgramModel(
      programId: entity.programId,
      programName: entity.programName,
      zones: entity.zones.map((e) => ZoneSettingModel.fromEntity(e)).toList(),
      timerAdjustPercent: entity.timerAdjustPercent,
      flowAdjustPercent: entity.flowAdjustPercent,
      moistureAdjustPercent: entity.moistureAdjustPercent,
      fertilizerAdjustPercent: entity.fertilizerAdjustPercent,
      mappedValves: entity.mappedValves.map((e) => NodeModel.fromEntity(e)).toList(),
      mappedMoistureSensors: entity.mappedMoistureSensors.map((e) => NodeModel.fromEntity(e)).toList(),
      mappedLevelSensors: entity.mappedLevelSensors.map((e) => NodeModel.fromEntity(e)).toList(),
    );
  }

  // ---------------- COMMAND TEMPLATES ----------------
  static const _zoneTimeSetCommand = 'ZONETIMERSETP:programId:zoneSetId';
  static const _zoneFlowSetCommand = 'FLOWSETP:programId:zoneSetId';
  static const _fertTimeSetCommand = 'FERTTIMERSETP:programIdF:channelNo:zoneSetId';
  static const _fertFlowSetCommand = 'FLOWFERTSETP:programIdF:channelNo:zoneSetId';
  static const _preTimeSetCommand = 'PRETIMERSETP:programId:zoneSetId';
  static const _postTimeSetCommand = 'POSTTIMERSETP:programId:zoneSetId';
  static const _preFlowSetCommand = 'SETPREFLOWP:programId:zoneSetId';
  static const _postFlowSetCommand = 'SETPOSTFLOWP:programId:zoneSetId';

  String _cmd(String template, String zoneSetId) =>
      template
          .replaceAll(':programId', programId.toString())
          .replaceAll(':zoneSetId', zoneSetId.padLeft(2, '0'));

  String _joinTimes(Iterable<String> values) {
    final formEightZone = [
      ...values.map((e) => e.replaceAll(':', '')),
      ...List.generate(8 - values.length, (index){
        return '0000';
      })
    ];
    return formEightZone.join(',');
  }

  String _joinLiters(Iterable<String> values) {
    final formEightZone = [
      ...values.map((e) => e.padLeft(5, '0')),
      ...List.generate(8 - values.length, (index){
        return '00000';
      })
    ];
    return formEightZone.join(',');
  }

  // ---------------- PAYLOAD BUILDERS ----------------
  String formZonesTimePayload({required String zoneSetId, required List<ZoneSettingModel> listOfZone}) =>
      '${_cmd(_zoneTimeSetCommand, zoneSetId)},'
          '${_joinTimes(listOfZone.map((e) => e.time))}';

  String formPreTimePayload({required String zoneSetId, required List<ZoneSettingModel> listOfZone}) =>
      '${_cmd(_preTimeSetCommand, zoneSetId)},'
          '${_joinTimes(listOfZone.map((e) => e.preTime))}';

  String formPostTimePayload({required String zoneSetId, required List<ZoneSettingModel> listOfZone}) =>
      '${_cmd(_postTimeSetCommand, zoneSetId)},'
          '${_joinTimes(listOfZone.map((e) => e.postTime))}';

  String formZonesFlowPayload({required String zoneSetId, required List<ZoneSettingModel> listOfZone}) =>
      '${_cmd(_zoneFlowSetCommand, zoneSetId)},'
          '${_joinLiters(listOfZone.map((e) => e.liters))}';

  String formPreFlowPayload({required String zoneSetId, required List<ZoneSettingModel> listOfZone}) =>
      '${_cmd(_preFlowSetCommand, zoneSetId)},'
          '${_joinLiters(listOfZone.map((e) => e.preLiters))}';

  String formPostFlowPayload({required String zoneSetId, required List<ZoneSettingModel> listOfZone}) =>
      '${_cmd(_postFlowSetCommand, zoneSetId)},'
          '${_joinLiters(listOfZone.map((e) => e.postLiters))}';

  String formFertTimeFlowPayload({
    required String zoneSetId,
    required int channelNo,
    required int method,
    required List<ZoneSettingModel> listOfZone
  }) {
    final template =
    method == 1 ? _fertTimeSetCommand : _fertFlowSetCommand;

    final cmd = template
        .replaceAll(':programId', programId.toString())
        .replaceAll(':zoneSetId', zoneSetId.padLeft(2, '0'))
        .replaceAll(':channelNo', channelNo.toString());

    final values = listOfZone.map(
          (e) => _channelValue(e, channelNo, method),
    );
    final formEightZone = [
      ...values,
      ...List.generate(8 - values.length, (index){
        return method == 1 ? '0000' : '00000';
      })
    ];

    return '$cmd,${formEightZone.join(',')}';
  }

  String _channelValue(
      ZoneSettingModel e,
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
    print("times => $times");
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
    required List<ZoneSettingModel> listOfZone
  }) {
    if (method == 1) {
      if (mode == 1) return formZonesTimePayload(zoneSetId: zoneSetId, listOfZone: listOfZone);
      if (mode == 2) return formPreTimePayload(zoneSetId: zoneSetId, listOfZone: listOfZone);
      if (mode == 3) {
        return formFertTimeFlowPayload(
          zoneSetId: zoneSetId,
          channelNo: channelNo,
          method: method, listOfZone: listOfZone,
        );
      }
      return formPostTimePayload(zoneSetId: zoneSetId, listOfZone: listOfZone);
    }

    if (mode == 1) return formZonesFlowPayload(zoneSetId: zoneSetId, listOfZone: listOfZone);
    if (mode == 2) return formPreFlowPayload(zoneSetId: zoneSetId, listOfZone: listOfZone);
    if (mode == 3) {
      return formFertTimeFlowPayload(
        zoneSetId: zoneSetId,
        channelNo: channelNo,
        method: method, listOfZone: listOfZone,
      );
    }
    return formPostFlowPayload(zoneSetId: zoneSetId, listOfZone: listOfZone);
  }
}