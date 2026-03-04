import '../../domain/entities/livemessage_entity.dart';

class LiveMessageModel extends LiveMessageEntity {
  const LiveMessageModel({
    required super.cd,
    required super.ct,
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
    required super.lastsync,
  });

  factory LiveMessageModel.fromLiveMessage(String? message, {String? typeCode, String? externalLastSync}) {
    if (message == null || message.trim().isEmpty || message.trim().toUpperCase() == "NA") {
      return _empty(externalLastSync);
    }

    final parts = message.split(',').map((s) => s.trim()).toList();

    String safeString(int index, String defaultValue) {
      if (index >= parts.length) return defaultValue;
      final val = parts[index];
      return val.isEmpty ? defaultValue : val;
    }

    List<String> safeList(int index, List<String> defaultValue, {String separator = ':'}) {
      if (index >= parts.length) return defaultValue;
      final str = parts[index];
      if (str.isEmpty || str.toUpperCase() == 'NA') return defaultValue;
      return str.split(separator).map((s) => s.trim()).toList();
    }

    String cd = '00/00/00';
    String ct = '00:00:00';
    if (externalLastSync != null && (externalLastSync.contains('\n') || externalLastSync.contains(' '))) {
      final tsParts = externalLastSync.split(RegExp(r'[\n ]'));
      if (tsParts.length >= 2) {
        ct = tsParts[0];
        cd = tsParts[1];
      }
    }

    // Default Values
    String motorOnOff = '0';
    String valveOnOff = '0';
    String liveDisplay1 = '';
    String liveDisplay2 = '';
    String rVoltage = '0';
    String yVoltage = '0';
    String bVoltage = '0';
    String ryVoltage = '0';
    String ybVoltage = '0';
    String brVoltage = '0';
    String rCurrent = '0';
    String yCurrent = '0';
    String bCurrent = '0';
    String phase = 'phase';
    String signal = '0';
    String modeOfOperation = '';
    String programName = '';
    String zoneNo = '0';
    String valveForZone = '0';
    String zoneDuration = '00:00:00';
    String zoneRemainingTime = '00:00:00';
    String prsIn = '0.0';
    String prsOut = '0.0';
    String flowRate = '0.0';
    String totalMeterFlow = '0';
    String wellLevel = '0';
    String wellPercent = "0";
    String runTimeToday = '00:00:00';
    String runTimePrevious = '00:00:00';
    String flowPrevDay = '0';
    String flowToday = '0';
    String moisture1 = '0';
    String moisture2 = '0';
    String energy = '0';
    String powerFactor = '0';
    List<String> fertStatus = ['0', '0', '0', '0', '0', '0'];
    List<String> fertValues = ['0', '0', '0', '0', '0', '0'];
    String batVolt = '0.0';
    String ec = "0";
    String ph = "0";
    String versionModule = '';
    String versionBoard = '';
    String lastsync = externalLastSync ?? '--';

    bool isPumpLive = typeCode == 'LD04' || message.startsWith('LD04');

    if (isPumpLive) {
      motorOnOff = safeString(1, '0');
      valveOnOff = safeString(2, '0');
      rVoltage = safeString(3, '0');
      yVoltage = safeString(4, '0');
      bVoltage = safeString(5, '0');
      ryVoltage = safeString(6, '0');
      ybVoltage = safeString(7, '0');
      brVoltage = safeString(8, '0');
      rCurrent = safeString(9, '0.0');
      yCurrent = safeString(10, '0.0');
      bCurrent = safeString(11, '0.0');
      phase = "3 PHASE";
      signal = safeString(47, '0');
      modeOfOperation = safeString(14, '');
      programName = safeString(15, '');
      zoneNo = safeString(16, '0');
      valveForZone = safeString(17, '');
      zoneDuration = safeString(18, '00:00:00');
      zoneRemainingTime = safeString(19, '00:00:00');
      prsIn = safeString(20, '0.0');
      prsOut = safeString(21, '0.0');
      flowRate = safeString(25, '0.0');
      wellLevel = safeString(23, '0');
      wellPercent = safeString(23, '0');
      runTimeToday = safeString(27, '00:00:00');
      runTimePrevious = safeString(28, '00:00:00');
      flowToday = safeString(29, '0');
      flowPrevDay = safeString(30, '0');
      moisture1 = safeString(31, '0');
      moisture2 = safeString(32, '0');
      energy = safeString(33, '0');
      powerFactor = safeString(34, '0');
      fertStatus = safeList(24, ['0', '0', '0', '0', '0', '0'], separator: ':');
      fertValues = safeList(36, ['0', '0', '0', '0', '0', '0'], separator: ';');
      batVolt = safeString(48, '0');
      ec = safeString(25, '0');
      ph = safeString(25, '0');
      versionModule = safeString(39, '');
      versionBoard = safeString(40, '');
    } else {
      motorOnOff = safeString(0, '0');
      valveOnOff = safeString(1, '0');
      liveDisplay1 = safeString(3, '');
      liveDisplay2 = safeString(4, '');
      rVoltage = safeString(5, '0');
      yVoltage = safeString(6, '0');
      bVoltage = safeString(7, '0');
      ryVoltage = safeString(8, '0');
      ybVoltage = safeString(9, '0');
      brVoltage = safeString(10, '0');
      rCurrent = safeString(11, '0.0');
      yCurrent = safeString(12, '0.0');
      bCurrent = safeString(13, '0.0');
      phase = safeString(5, '0') != '0' ? "3 PHASE" : "NA";
      signal = safeString(37, '0');
      modeOfOperation = safeString(14, '');
      programName = safeString(15, '');
      zoneNo = safeString(16, '0');
      valveForZone = safeString(17, '');
      zoneDuration = safeString(18, '00:00:00');
      zoneRemainingTime = safeString(19, '00:00:00');
      prsIn = safeString(20, '0.0');
      prsOut = safeString(21, '0.0');
      flowRate = safeString(22, '0.0');
      wellLevel = safeString(23, '0');
      wellPercent = safeString(23, '0');
      runTimeToday = safeString(27, '00:00:00');
      runTimePrevious = safeString(28, '00:00:00');
      flowToday = safeString(29, '0');
      flowPrevDay = safeString(30, '0');
      moisture1 = safeString(31, '0');
      moisture2 = safeString(32, '0');
      energy = safeString(33, '0');
      powerFactor = safeString(34, '0');
      fertStatus = safeList(24, ['0', '0', '0', '0', '0', '0'], separator: ':');
      fertValues = safeList(36, ['0', '0', '0', '0', '0', '0'], separator: ';');
      batVolt = safeString(38, '0');
      ec = safeString(25, '0');
      ph = safeString(25, '0');
      versionModule = safeString(39, '');
      versionBoard = safeString(40, '');
    }

    return LiveMessageModel(
      cd: cd,
      ct: ct,
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
      batVolt: batVolt,
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
      lastsync: lastsync,
    );
  }

  static LiveMessageModel _empty(String? sync) {
    String cd = '00/00/00';
    String ct = '00:00:00';
    if (sync != null && (sync.contains('\n') || sync.contains(' '))) {
      final tsParts = sync.split(RegExp(r'[\n ]'));
      if (tsParts.length >= 2) {
        ct = tsParts[0];
        cd = tsParts[1];
      }
    }
    return LiveMessageModel(
      cd: cd,
      ct: ct,
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
      rCurrent: '0',
      yCurrent: '0',
      bCurrent: '0',
      phase: 'NA',
      signal: '0',
      batVolt: '0',
      modeOfOperation: '',
      programName: '',
      zoneNo: '0',
      valveForZone: '0',
      zoneDuration: '00:00:00',
      zoneRemainingTime: '00:00:00',
      prsIn: '0.0',
      prsOut: '0.0',
      flowRate: '0.0',
      wellLevel: '0',
      wellPercent: '0',
      fertStatus: const ['0', '0', '0', '0', '0', '0'],
      ec: '0',
      ph: '0',
      totalMeterFlow: '0',
      runTimeToday: '00:00:00',
      runTimePrevious: '00:00:00',
      flowPrevDay: '0',
      flowToday: '0',
      moisture1: '0',
      moisture2: '0',
      energy: '0',
      powerFactor: '0',
      fertValues: const ['0', '0', '0', '0', '0', '0'],
      versionModule: '',
      versionBoard: '',
      lastsync: sync ?? '--',
    );
  }
}
