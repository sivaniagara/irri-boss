
import '../../domain/entities/livemessage_entity.dart';

class LiveMessageModel extends LiveMessageEntity {
  const LiveMessageModel({
    required super.motorOnOff,
    required super.valveOnOff,
    required super.liveDisplay1,
    required super.liveDisplay2,
    required super.rVoltage,
    required super.yVoltage,
    required super.bVoltage,
    required super.ryVoltage,
    required super.ybVoltage,
    required super.brVoltage,
    required super.rCurrent,
    required super.yCurrent,
    required super.bCurrent,
    required super.phase,
    required super.signal,
    required super.batVolt,
    required super.modeOfOperation,
    required super.programName,
    required super.zoneNo,
    required super.valveForZone,
    required super.zoneDuration,
    required super.zoneRemainingTime,
    required super.prsIn,
    required super.prsOut,
    required super.flowRate,
    required super.wellLevel,
    required super.wellPercent,
    required super.fertStatus,
    required super.ec,
    required super.ph,
    required super.totalMeterFlow,
    required super.runTimeToday,
    required super.runTimePrevious,
    required super.flowPrevDay,
    required super.flowToday,
    required super.moisture1,
    required super.moisture2,
    required super.energy,
    required super.powerFactor,
    required super.fertValues,
    required super.versionModule,
    required super.versionBoard,
  });

  /// Parse from liveMessage string (MQTT cM field)
  factory LiveMessageModel.fromLiveMessage(String? message) {
    if (message == null || message.trim().isEmpty || message.trim().toUpperCase() == "NA") {
      return const LiveMessageModel(
        motorOnOff: '0',
        valveOnOff: '0',
        liveDisplay1: '',
        liveDisplay2: '',
        rVoltage: '0',
        yVoltage: '0',
        bVoltage: '0',
        ryVoltage: '0',
        ybVoltage: '0',
        brVoltage: '0',
        rCurrent: '0.0',
        yCurrent: '0.0',
        bCurrent: '0.0',
        phase: 'Phase',
        signal: '00',
        batVolt: '0.0',
        modeOfOperation: '',
        programName: '',
        zoneNo: '0',
        valveForZone: '',
        zoneDuration: '00:00:00',
        zoneRemainingTime: '00:00:00',
        prsIn: '0.0',
        prsOut: '0.0',
        flowRate: '0.0',
        wellLevel: '0',
        wellPercent: '0',
        fertStatus: <String>['0','0','0','0','0','0',],
        ec: '0',
        ph: '0',
        totalMeterFlow: '0',
        runTimeToday: '0',
        runTimePrevious: '0',
        flowPrevDay: '00:00:00',
        flowToday: '00:00:00',
        moisture1: '0',
        moisture2: '0',
        energy: '0',
        powerFactor: '0',
        fertValues: <String>['0','0','0','0','0','0',],
        versionModule: '',
        versionBoard: '',
      );
    }

    final parts = message.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

    // Safe access helper
    String safeString(int index, String defaultValue) => index < parts.length ? parts[index] : defaultValue;
    List<String> safeList(int index, List<String> defaultValue) {
      if (index >= parts.length) return defaultValue; // prevent RangeError

      final str = parts[index].trim();
      if (str.isEmpty || str.toUpperCase() == 'NA') return defaultValue;

      if (index == 24) {
        return str.split(':').map((s) => s.trim()).toList();
      } else if (index == 36) {
        return str.split(';').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      }
      return [str];
    }

    // Parse specific fields
    final motorOnOff = safeString(0, '0');
    final valveOnOff = safeString(1, '0');
    final liveDisplay1 = safeString(3, '');
    final liveDisplay2 = safeString(4, '');
    final rVoltage = safeString(5, '0');
    final ryVoltage = safeString(6, '0');
    final yVoltage = safeString(7, '0');
    final ybVoltage = safeString(8, '0');
    final bVoltage = safeString(9, '0');
    final brVoltage = safeString(10, '0');
    final rCurrent = safeString(11, '0.0');
    final yCurrent = safeString(12, '0.0');
    final bCurrent = safeString(13, '0.0');
    final phase =  getPhaseValue(rVoltage,yVoltage,bVoltage);
    final signal = safeString(37, '0.0');
     final modeOfOperation = safeString(14, '');
    final programName = safeString(15, '');
    final zoneNo = safeString(16, '0');
    final valveForZone = safeString(17, '');
    final zoneDuration = safeString(18, '00:00:00');
    final zoneRemainingTime = safeString(19, '00:00:00');
    final prsIn = safeString(20, '0.0');
    final prsOut = safeString(21, '0.0');
    final flowRateTemp = safeString(25, '0.0:0');
    final flowParts = flowRateTemp.split(':');
    final flowRate = flowParts.isNotEmpty ? flowParts[0] : '0.0';
    final totalMeterFlow = flowParts.isNotEmpty && flowParts.length > 1 ? flowParts[1] : '0';

    final result = parseWellLevel(safeString(23, '0'));
    final wellLevel =  result["level"] ?? '0';
    final wellPercent =  result["percentage"] ?? "0";
    final runTimeToday = safeString(27, '00:00:00');
    final flowPrevDay = safeString(29, '0');
    final flowToday = safeString(30, '0');
    final moisture1 = safeString(31, '0');
    final moisture2 = safeString(32, '0');
    final energy = safeString(33, '0');
    final powerFactor = safeString(34, '0');

    // Fert values
    final fertValues = safeList(24, <String>['0','0','0','0','0','0',]);
    final fertStatus = safeList(36, <String>['0','0','0','0','0','0',]);
     // final batvolt = fertStatus.length > 8 ? fertStatus[8] : '0.0';
     final batvolt = fertStatus.length > 8 ? fertStatus[8] : '0.0';
    // List<String> fertStatus = <String>[];
    String runTimePrevious = safeString(28, '00:00:00');
    List<String> ecph = parts.length < 23 ? parts[25].split(':') : ['0:0'];
    final ec = ecph.isNotEmpty ? ecph[0] : "0";
    final ph = ecph.isNotEmpty && ecph.length > 1 ? ecph[1] : "0";


     final versionModule = safeString(39, '');
    final versionBoard = safeString(40, '');

    return LiveMessageModel(
      motorOnOff: motorOnOff,
      valveOnOff: valveOnOff,
      liveDisplay1: liveDisplay1,
      liveDisplay2: liveDisplay2,
      rVoltage: rVoltage,
      yVoltage: yVoltage,
      bVoltage: bVoltage,
      ryVoltage: ryVoltage,
      ybVoltage: ybVoltage,
      brVoltage: brVoltage,
      rCurrent: rCurrent,
      yCurrent: yCurrent,
      bCurrent: bCurrent,
      phase: phase,
      signal: signal,
      batVolt: batvolt,
      modeOfOperation: modeOfOperation,
      programName: programName,
      zoneNo: zoneNo,
      valveForZone: valveForZone,
      zoneDuration: zoneDuration,
      zoneRemainingTime: zoneRemainingTime,
      prsIn: prsIn,
      prsOut: prsOut,
      flowRate: flowRate,
      wellLevel: wellLevel,
      wellPercent: wellPercent,
      fertStatus: fertStatus,
      ec: ec,
      ph: ph,
      totalMeterFlow: totalMeterFlow,
      runTimeToday: runTimeToday,
      runTimePrevious: runTimePrevious,
      flowPrevDay: flowPrevDay,
      flowToday: flowToday,
      moisture1: moisture1,
      moisture2: moisture2,
      energy: energy,
      powerFactor: powerFactor,
      fertValues: fertValues,
      versionModule: versionModule,
      versionBoard: versionBoard,
    );
  }

  /// Convert back to JSON-like map (optional)
  Map<String, dynamic> toMap() => {
    "motorOnOff": motorOnOff,
    "valveOnOff": valveOnOff,
    "liveDisplay1": liveDisplay1,
    "liveDisplay2": liveDisplay2,
    "rVoltage": rVoltage,
    "yVoltage": yVoltage,
    "bVoltage": bVoltage,
    "ryVoltage": ryVoltage,
    "ybVoltage": ybVoltage,
    "brVoltage": brVoltage,
    "rCurrent": rCurrent,
    "yCurrent": yCurrent,
    "bCurrent": bCurrent,
    "phase": phase,
    "signal": signal,
    "batVolt": batVolt,
    "modeOfOperation": modeOfOperation,
    "programName": programName,
    "zoneNo": zoneNo,
    "valveForZone": valveForZone,
    "zoneDuration": zoneDuration,
    "zoneRemainingTime": zoneRemainingTime,
    "prsIn": prsIn,
    "prsOut": prsOut,
    "flowRate": flowRate,
    "wellLevel": wellLevel,
    "wellPercent": wellPercent,
    "fertStatus": fertStatus,
    "ec": ec,
    "ph": ph,
    "totalMeterFlow": totalMeterFlow,
    "runTimeToday": runTimeToday,
    "runTimePrevious": runTimePrevious,
    "flowPrevDay": flowPrevDay,
    "flowToday": flowToday,
    "moisture1": moisture1,
    "moisture2": moisture2,
    "energy": energy,
    "powerFactor": powerFactor,
    "fertValues": fertValues,
    "versionModule": versionModule,
    "versionBoard": versionBoard,
  };
}
String getPhaseValue(String rVoltage, String yVoltage, String bVoltage) {
  String phaseVal = "";

  if (rVoltage != "000" && yVoltage != "000" && bVoltage != "000") {
    phaseVal = "3-Phase";
  } else if ((rVoltage != "000" && yVoltage != "000" && bVoltage == "000") ||
      (rVoltage == "000" && yVoltage != "000" && bVoltage != "000") ||
      (rVoltage != "000" && yVoltage == "000" && bVoltage != "000")) {
    phaseVal = "2-phase";
  } else if ((rVoltage != "000" && yVoltage == "000" && bVoltage == "000") ||
      (rVoltage == "000" && yVoltage == "000" && bVoltage != "000") ||
      (rVoltage == "000" && yVoltage != "000" && bVoltage == "000")) {
    phaseVal = "1-phase";
  } else {
    phaseVal = "phase";
  }

  return phaseVal;
}

Map<String, String> parseWellLevel(String input) {
  String level = "0";
  String percentage = "0";

  if (input.contains("F-")) {
    final parts = input.split("F-");
    if (parts.isNotEmpty) {
      level = parts.first;
      if (parts.length > 1) {
        percentage = parts.last;
      }
    }
  }

  return {"level": level, "percentage": percentage};
}
