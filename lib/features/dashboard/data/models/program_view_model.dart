import '../../domain/entities/livemessage_entity.dart';

class ProgramViewModel {
  final String programName;
  final String valveStatus;
  final String irrigationMode;
  final String dosingMode;
  final String decideLast;
  final String decideFeedbackLast;
  final String delayValve;
  final String feedbackTime;
  final String dripCycRst;
  final String dripCycRstTime;
  final String zoneCycRst;
  final String programStartNumber;
  final String sumpStatus;
  final String dripSumpStatus;
  final String dayCountRtcTimer;
  final String skipDays;
  final String skipDaysStatus;

  final List<String> rtcTimers;
  final String rtcOnOff;
  final List<String> adjustPercent;

  final List<String> fertilizerStatus;
  final List<String> fertilizerRates;
  final List<String> ventFlows;

  final String preQty;
  final String postQty;
  final String preTime;
  final String postTimePercent;

  final String lastSync;

  const ProgramViewModel._({
    required this.programName,
    required this.valveStatus,
    required this.irrigationMode,
    required this.dosingMode,
    required this.decideLast,
    required this.decideFeedbackLast,
    required this.delayValve,
    required this.feedbackTime,
    required this.dripCycRst,
    required this.dripCycRstTime,
    required this.zoneCycRst,
    required this.programStartNumber,
    required this.sumpStatus,
    required this.dripSumpStatus,
    required this.dayCountRtcTimer,
    required this.skipDays,
    required this.skipDaysStatus,
    required this.rtcTimers,
    required this.rtcOnOff,
    required this.adjustPercent,
    required this.fertilizerStatus,
    required this.fertilizerRates,
    required this.ventFlows,
    required this.preQty,
    required this.postQty,
    required this.preTime,
    required this.postTimePercent,
    required this.lastSync,
  });

  // Added for compatibility with UI snippets
  List<String> get fertilizerSettingsData => [
    fertilizerStatus.join(":"),
    fertilizerRates.join(":"),
    ventFlows.join(":"),
  ];

  factory ProgramViewModel.fromRawString(String raw, {String? externalLastSync}) {
    var parts = raw.split(',').map((e) => e.trim()).toList();

    if (parts.isNotEmpty && (parts[0] == 'V01' || parts[0] == 'V02')) {
      parts = parts.sublist(1);
    }

    String safeGet(int index, {String defaultValue = ''}) {
      return (index >= 0 && index < parts.length) ? parts[index] : defaultValue;
    }

    List<String> getList(int index, int count, String def, {String sep = ':'}) {
      final rawVal = safeGet(index);
      if (rawVal.isEmpty) return List.filled(count, def);
      final listParts = rawVal.split(sep).map((e) => e.trim()).toList();
      if (listParts.length >= count) return listParts.sublist(0, count);
      return [...listParts, ...List.filled(count - listParts.length, def)];
    }

    final rtcTimers = parts.length >= 21
        ? parts.sublist(17, 21).map((e) => e.trim()).toList()
        : List.filled(4, '00:00;00:00');

    return ProgramViewModel._(
      programName: safeGet(0),
      valveStatus: safeGet(1),
      irrigationMode: safeGet(2),
      dosingMode: safeGet(3),
      decideLast: safeGet(4),
      decideFeedbackLast: safeGet(5),
      delayValve: safeGet(6),
      feedbackTime: safeGet(7),
      dripCycRst: safeGet(8),
      dripCycRstTime: safeGet(9),
      zoneCycRst: safeGet(10),
      programStartNumber: safeGet(11),
      sumpStatus: safeGet(12),
      dripSumpStatus: safeGet(13),
      dayCountRtcTimer: safeGet(14),
      skipDays: safeGet(15),
      skipDaysStatus: safeGet(16),
      rtcTimers: rtcTimers,
      rtcOnOff: safeGet(21),
      adjustPercent: getList(22, 4, '100'),
      fertilizerStatus: getList(23, 6, '0'),
      fertilizerRates: getList(24, 6, '0'),
      ventFlows: getList(25, 6, '0.0'),
      preQty: safeGet(26),
      postQty: safeGet(27),
      preTime: safeGet(28),
      postTimePercent: safeGet(29, defaultValue: safeGet(28)),
      lastSync: externalLastSync ?? '--',
    );
  }

  factory ProgramViewModel.fromLiveMessage(LiveMessageEntity live) {
    List<String> rtc = List.filled(4, '00:00;00:00');
    if (live.fertValues.length >= 8) {
      rtc = [
        '${live.fertValues[0]};${live.fertValues[1]}',
        '${live.fertValues[2]};${live.fertValues[3]}',
        '${live.fertValues[4]};${live.fertValues[5]}',
        '${live.fertValues[6]};${live.fertValues[7]}',
      ];
    }

    return ProgramViewModel._(
      programName: live.programName,
      valveStatus: live.valveOnOff,
      irrigationMode: live.modeOfOperation,
      dosingMode: "NA",
      decideLast: "0",
      decideFeedbackLast: "0",
      delayValve: "0",
      feedbackTime: "0",
      dripCycRst: "0",
      dripCycRstTime: "00:00",
      zoneCycRst: "0",
      programStartNumber: "1",
      sumpStatus: "0",
      dripSumpStatus: "0",
      dayCountRtcTimer: "0",
      skipDays: "0",
      skipDaysStatus: "0",
      rtcTimers: rtc,
      rtcOnOff: "0",
      adjustPercent: List.filled(4, '100'),
      fertilizerStatus: live.fertStatus,
      fertilizerRates: live.fertValues,
      ventFlows: List.filled(6, '0.0'),
      preQty: "0",
      postQty: "0",
      preTime: "00:00",
      postTimePercent: "0",
      lastSync: live.lastsync,
    );
  }
}

class ZoneViewModel {
  final String zoneNumber;
  final String zoneName;
  final String valveId;
  final String irrigationTime;
  final String irrigationFlow;
  final String moistureSetting;
  final List<String> dripCyclicTimers;

  final List<String> fertTimers;
  final List<String> fertFlows;
  final List<String> pumpSelections;

  ZoneViewModel({
    required this.zoneNumber,
    required this.zoneName,
    required this.valveId,
    required this.irrigationTime,
    required this.irrigationFlow,
    required this.moistureSetting,
    required this.dripCyclicTimers,
    required this.fertTimers,
    required this.fertFlows,
    required this.pumpSelections,
  });

  // Added for compatibility with UI snippets
  String get activeValves => valveId;
  String get fertigationTimes => fertTimers.join("-");
  String get fertigationFlows => fertFlows.join(":");

  factory ZoneViewModel.fromRawString(String rawString) {
    // 1. First split by semicolon to see the internal structure
    var parts = rawString.trim().split(";");

    // 2. Handle cases where "V02" is the first semicolon part or prefixed to it
    if (parts.isNotEmpty) {
      if (parts[0] == "V02") {
        // If it's JUST "V02", remove it and the zone number is now at parts[0]
        parts = parts.sublist(1);
      } else if (parts[0].startsWith("V02")) {
        // If it's "V021", strip "V02" and the zone number remains at parts[0]
        parts[0] = parts[0].replaceFirst("V02", "").trim();
      }
    }

    String safeGet(int index, {String defaultValue = ''}) {
      return (index >= 0 && index < parts.length) ? parts[index].trim() : defaultValue;
    }

    final zoneNum = safeGet(0);

    final fertTimersStr = safeGet(4);
    final fertFlowsStr = safeGet(5);

    final fertTimersList = fertTimersStr.split("-").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final fertFlowsList = fertFlowsStr.split(":").map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final pumps = parts.length > 6 ? parts.sublist(6, parts.length > 10 ? 10 : parts.length) : <String>[];

    return ZoneViewModel(
      zoneNumber: zoneNum,
      zoneName: "Zone $zoneNum",
      valveId: safeGet(3),
      irrigationTime: safeGet(1),
      irrigationFlow: safeGet(2),
      moistureSetting: "",
      dripCyclicTimers: [],
      fertTimers: fertTimersList,
      fertFlows: fertFlowsList,
      pumpSelections: pumps,
    );
  }
}
