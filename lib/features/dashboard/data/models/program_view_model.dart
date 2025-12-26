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
  final List<String> fertilizerRates;

  final String preQty;
  final String postQty;
  final String preTime;
  final String postTimePercent;

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
    required this.fertilizerRates,
    required this.preQty,
    required this.postQty,
    required this.preTime,
    required this.postTimePercent
  });

  factory ProgramViewModel.fromRawString(String raw) {
    final parts = raw.split(',');

    final name = parts.isNotEmpty ? parts[0] : '';
    final mode = parts.length > 1 ? parts[1] : '';
    final irrigationMode = parts.length > 2 ? parts[2] : '';
    final dosing = parts.length > 3 ? parts[3] : '';
    final zoneCount = parts.length > 4 ? parts[4] : '';
    final irrigationTime = parts.length > 5 ? parts[5] : '';
    final dosingTime = parts.length > 6 ? parts[6] : '';
    final feedbackTime = parts.length > 7 ? parts[7] : '';

    final rtcTimers = parts.length > 20
        ? parts.sublist(17, 21)
        : List.filled(4, '00:00');

    final adjustPercent = parts.length > 22 && parts[22].isNotEmpty
        ? parts[22].split(':')
        : List.filled(4, '100');

    final fertilizerRates = parts.length > 23 ? parts.sublist(23, 29)
        : List.filled(6, '0.0');

    final ventFlows = parts.length > 24 && parts[24].isNotEmpty
        ? parts[24].split(':')
        : List.filled(6, '0.0');

    return ProgramViewModel._(
      programName: name,
      valveStatus: mode,
      irrigationMode: irrigationMode,
      dosingMode: dosing,
      decideLast: zoneCount,
      decideFeedbackLast: irrigationTime,
      delayValve: dosingTime,
      feedbackTime: feedbackTime,
      dripCycRst: parts[8],
      dripCycRstTime: parts[9],
      zoneCycRst: parts[10],
      programStartNumber: parts[11],
      sumpStatus: parts[12],
      dripSumpStatus: parts[13],
      dayCountRtcTimer: parts[14],
      skipDays: parts[15],
      skipDaysStatus: parts[16],
      rtcTimers: rtcTimers,
      rtcOnOff: parts[21],
      adjustPercent: parts[22].split(':'),
      fertilizerRates: parts.sublist(23, 26),
      preQty: parts[26],
      postQty: parts[27],
      preTime: parts[28],
      postTimePercent: parts[28]
    );
  }
}

class ZoneViewModel {
  final String zoneNumber;
  final String irrigationTime;
  final String irrigationFlow;
  final String activeValves;
  final String fertigationTimes;
  final String fertigationFlows;
  final String pump1;
  final String pump2;
  final String pump3;
  final String pump4;

  ZoneViewModel({
    required this.zoneNumber,
    required this.irrigationTime,
    required this.irrigationFlow,
    required this.activeValves,
    required this.fertigationTimes,
    required this.fertigationFlows,
    required this.pump1,
    required this.pump2,
    required this.pump3,
    required this.pump4
  });

  factory ZoneViewModel.fromRawString(String rawString) {
    final parts = rawString.split(";");
    return ZoneViewModel(
        zoneNumber: parts[0],
        irrigationTime: parts[1],
        irrigationFlow: parts[2],
        activeValves: parts[3],
        fertigationTimes: parts[4],
        fertigationFlows: parts[5],
        pump1: parts[6],
        pump2: parts[7],
        pump3: parts[8],
        pump4: parts[9]
    );
  }
}