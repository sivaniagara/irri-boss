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
    super.fullMessage = '',
    super.msgDesc = '',
  });

  factory LiveMessageModel.fromLiveMessage(String? message,
      {String? typeCode, String? externalLastSync}) {
    if (message == null ||
        message.trim().isEmpty ||
        message.trim().toUpperCase() == "NA") {
      return _empty(externalLastSync);
    }

    // Check if this looks like stale cached data (all zeros or placeholder values)
    final parts = message.split(',').map((s) => s.trim()).toList();
    if (parts.length >= 10) {
      bool looksLikeStaleData = true;
      // Check if first 10 values are all zeros, empty, or obvious placeholders
      for (int i = 0; i < 10 && i < parts.length; i++) {
        final val = parts[i];
        if (val.isNotEmpty &&
            val != '0' &&
            val != '0.0' &&
            val != 'NA' &&
            val != '--') {
          looksLikeStaleData = false;
          break;
        }
      }
      if (looksLikeStaleData) {
        return _empty(externalLastSync);
      }
    }

    String safeString(int index, String defaultValue) {
      if (index >= parts.length) return defaultValue;
      final val = parts[index];
      return val.isEmpty ? defaultValue : val;
    }

    List<String> safeList(int index, List<String> defaultValue,
        {String separator = ':'}) {
      if (index >= parts.length) return defaultValue;
      final str = parts[index];
      if (str.isEmpty || str.toUpperCase() == 'NA') return defaultValue;
      return str.split(separator).map((s) => s.trim()).toList();
    }

    bool looksLikeMode(String value) => value.toUpperCase().contains('MODE');

    String cd = '00/00/00';
    String ct = '00:00:00';
    if (externalLastSync != null &&
        (externalLastSync.contains('\n') || externalLastSync.contains(' '))) {
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
      motorOnOff = safeString(0, '0');

      // LD04 comes in two known shapes:
      // - Single pump: [motorOnOff, rV, yV, bV, ryV, ybV, brV, rI, yI, bI, mode, ...]
      // - Double pump: [motor1OnOff, motor2OnOff, rV, yV, bV, ryV, ybV, brV, rI, yI, bI, mode, ...]
      //
      // If we parse a double-pump packet as single-pump, `brVoltage` (often ~400+) is misread as `rCurrent`,
      // leading to bogus ~415A values in the UI.
      //
      // Double-pump detection: position 1 should be motor status (0/1) AND position 10 is not a mode but position 11 is
      bool looksLikeMotorStatus(String value) => value == '0' || value == '1';
      final int ld04Offset = (looksLikeMotorStatus(safeString(1, '')) &&
              !looksLikeMode(safeString(10, '')) &&
              looksLikeMode(safeString(11, '')))
          ? 1
          : 0;

      rVoltage = safeString(1 + ld04Offset, '0');
      yVoltage = safeString(2 + ld04Offset, '0');
      bVoltage = safeString(3 + ld04Offset, '0');
      ryVoltage = safeString(4 + ld04Offset, '0');
      ybVoltage = safeString(5 + ld04Offset, '0');
      brVoltage = safeString(6 + ld04Offset, '0');
      rCurrent = safeString(7 + ld04Offset, '0.0');
      yCurrent = safeString(8 + ld04Offset, '0.0');
      bCurrent = safeString(9 + ld04Offset, '0.0');
      phase = "3 PHASE";
      modeOfOperation = safeString(10 + ld04Offset, '');
      programName = safeString(11 + ld04Offset, '');
      zoneNo = safeString(12 + ld04Offset, '0');
      valveForZone = safeString(15 + ld04Offset, '');
      zoneDuration = safeString(13 + ld04Offset, '00:00:00');
      zoneRemainingTime = safeString(14 + ld04Offset, '00:00:00');
      prsIn = safeString(19 + ld04Offset, '0.0');
      prsOut = safeString(20 + ld04Offset, '0.0');
      flowRate = safeString(21 + ld04Offset, '0.0');

      // Well data at 38
      String rawWell = safeString(38 + ld04Offset, '0');
      if (rawWell.contains('F-')) {
        final wellParts = rawWell.split('F-');
        wellLevel = wellParts[0];
        wellPercent = wellParts.length > 1 ? wellParts[1] : '0';
      } else {
        wellPercent = rawWell;
        wellLevel = safeString(39 + ld04Offset, '0');
      }

      fertStatus = safeList(24 + ld04Offset, ['0', '0', '0', '0', '0', '0'],
          separator: ':');

      // EC and PH
      String rawEcPh = safeString(23 + ld04Offset, '0:0');
      if (rawEcPh.contains(':')) {
        final ecPhParts = rawEcPh.split(':');
        ec = ecPhParts[0];
        ph = ecPhParts.length > 1 ? ecPhParts[1] : '0';
      } else {
        ec = rawEcPh;
        ph = safeString(25 + ld04Offset, '0');
      }
      totalMeterFlow = safeString(26 + ld04Offset, '0');

      runTimeToday = safeString(27 + ld04Offset, '00:00:00');
      runTimePrevious = safeString(28 + ld04Offset, '00:00:00');
      flowToday = safeString(29 + ld04Offset, '0');
      flowPrevDay = safeString(30 + ld04Offset, '0');
      moisture1 = safeString(31 + ld04Offset, '0');
      moisture2 = safeString(32 + ld04Offset, '0');
      energy = safeString(33 + ld04Offset, '0');
      powerFactor = safeString(34 + ld04Offset, '0');
      fertValues = safeList(36 + ld04Offset, ['0', '0', '0', '0', '0', '0'],
          separator: ';');
      versionModule = safeString(40 + ld04Offset, '');
      versionBoard = safeString(44 + ld04Offset, '');
      signal = safeString(46 + ld04Offset, '0');
      batVolt = safeString(47 + ld04Offset, '0');
    } else {
      // Standard LD01 / LD06
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
      modeOfOperation = safeString(14, '');
      programName = safeString(15, '');
      zoneNo = safeString(16, '0');
      valveForZone = safeString(17, '');
      zoneDuration = safeString(18, '00:00:00');
      zoneRemainingTime = safeString(19, '00:00:00');
      prsIn = safeString(20, '0.0');
      prsOut = safeString(21, '0.0');
      flowRate = safeString(22, '0.0');

      // Well data at 23
      String rawWell = safeString(23, '0');
      if (rawWell.contains('F-')) {
        final wellParts = rawWell.split('F-');
        wellLevel = wellParts[0];
        wellPercent = wellParts.length > 1 ? wellParts[1] : '0';
      } else {
        wellPercent = rawWell;
        wellLevel = safeString(41, '0');
      }

      fertStatus = safeList(24, ['0', '0', '0', '0', '0', '0'], separator: ':');

      // EC and PH packed at 25 (e.g., 0.0:0.0)
      String rawEcPh = safeString(25, '0:0');
      if (rawEcPh.contains(':')) {
        final ecPhParts = rawEcPh.split(':');
        ec = ecPhParts[0];
        ph = ecPhParts.length > 1 ? ecPhParts[1] : '0';
      } else {
        ec = rawEcPh;
        ph = safeString(26, '0');
      }
      totalMeterFlow = safeString(26, '0');

      runTimeToday = safeString(27, '00:00:00');
      runTimePrevious = safeString(28, '00:00:00');
      flowPrevDay = safeString(29, '0');
      flowToday = safeString(30, '0');
      moisture1 = safeString(31, '0');
      moisture2 = safeString(32, '0');
      energy = safeString(33, '0');
      powerFactor = safeString(34, '0');
      fertValues = safeList(36, ['0', '0', '0', '0', '0', '0'], separator: ';');

      // Signal and Battery indices adjusted for LD01 based on provided samples
      batVolt = safeString(38, '0');
      signal = safeString(37, '0');
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
      fullMessage: message,
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
      rVoltage: '--',
      yVoltage: '--',
      bVoltage: '--',
      ryVoltage: '--',
      ybVoltage: '--',
      brVoltage: '--',
      rCurrent: '--',
      yCurrent: '--',
      bCurrent: '--',
      phase: 'NA',
      signal: '--',
      batVolt: '--',
      modeOfOperation: '',
      programName: '',
      zoneNo: '0',
      valveForZone: '0',
      zoneDuration: '00:00:00',
      zoneRemainingTime: '00:00:00',
      prsIn: '--',
      prsOut: '--',
      flowRate: '--',
      wellLevel: '--',
      wellPercent: '--',
      fertStatus: const ['0', '0', '0', '0', '0', '0'],
      ec: '--',
      ph: '--',
      totalMeterFlow: '--',
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
      fullMessage: '',
      msgDesc: '',
    );
  }

  @override
  LiveMessageModel copyWith({
    String? cd,
    String? ct,
    String? motorOnOff,
    String? valveOnOff,
    String? liveDisplay1,
    String? liveDisplay2,
    String? rVoltage,
    String? yVoltage,
    String? bVoltage,
    String? ryVoltage,
    String? ybVoltage,
    String? brVoltage,
    String? rCurrent,
    String? yCurrent,
    String? bCurrent,
    String? phase,
    String? signal,
    String? batVolt,
    String? modeOfOperation,
    String? programName,
    String? zoneNo,
    String? valveForZone,
    String? zoneDuration,
    String? zoneRemainingTime,
    String? prsIn,
    String? prsOut,
    String? flowRate,
    String? wellLevel,
    String? wellPercent,
    List<String>? fertStatus,
    String? ec,
    String? ph,
    String? totalMeterFlow,
    String? runTimeToday,
    String? runTimePrevious,
    String? flowPrevDay,
    String? flowToday,
    String? moisture1,
    String? moisture2,
    String? energy,
    String? powerFactor,
    List<String>? fertValues,
    String? versionModule,
    String? versionBoard,
    String? lastsync,
    String? fullMessage,
    String? msgDesc,
  }) {
    return LiveMessageModel(
      cd: cd ?? this.cd,
      ct: ct ?? this.ct,
      motorOnOff: motorOnOff ?? this.motorOnOff,
      valveOnOff: valveOnOff ?? this.valveOnOff,
      liveDisplay1: liveDisplay1 ?? this.liveDisplay1,
      liveDisplay2: liveDisplay2 ?? this.liveDisplay2,
      rVoltage: rVoltage ?? this.rVoltage,
      yVoltage: yVoltage ?? this.yVoltage,
      bVoltage: bVoltage ?? this.bVoltage,
      ryVoltage: ryVoltage ?? this.ryVoltage,
      ybVoltage: ybVoltage ?? this.ybVoltage,
      brVoltage: brVoltage ?? this.brVoltage,
      rCurrent: rCurrent ?? this.rCurrent,
      yCurrent: yCurrent ?? this.yCurrent,
      bCurrent: bCurrent ?? this.bCurrent,
      phase: phase ?? this.phase,
      signal: signal ?? this.signal,
      batVolt: batVolt ?? this.batVolt,
      modeOfOperation: modeOfOperation ?? this.modeOfOperation,
      programName: programName ?? this.programName,
      zoneNo: zoneNo ?? this.zoneNo,
      valveForZone: valveForZone ?? this.valveForZone,
      zoneDuration: zoneDuration ?? this.zoneDuration,
      zoneRemainingTime: zoneRemainingTime ?? this.zoneRemainingTime,
      prsIn: prsIn ?? this.prsIn,
      prsOut: prsOut ?? this.prsOut,
      flowRate: flowRate ?? this.flowRate,
      wellLevel: wellLevel ?? this.wellLevel,
      wellPercent: wellPercent ?? this.wellPercent,
      fertStatus: fertStatus ?? this.fertStatus,
      ec: ec ?? this.ec,
      ph: ph ?? this.ph,
      totalMeterFlow: totalMeterFlow ?? this.totalMeterFlow,
      runTimeToday: runTimeToday ?? this.runTimeToday,
      runTimePrevious: runTimePrevious ?? this.runTimePrevious,
      flowPrevDay: flowPrevDay ?? this.flowPrevDay,
      flowToday: flowToday ?? this.flowToday,
      moisture1: moisture1 ?? this.moisture1,
      moisture2: moisture2 ?? this.moisture2,
      energy: energy ?? this.energy,
      powerFactor: powerFactor ?? this.powerFactor,
      fertValues: fertValues ?? this.fertValues,
      versionModule: versionModule ?? this.versionModule,
      versionBoard: versionBoard ?? this.versionBoard,
      lastsync: lastsync ?? this.lastsync,
      fullMessage: fullMessage ?? this.fullMessage,
      msgDesc: msgDesc ?? this.msgDesc,
    );
  }
}
