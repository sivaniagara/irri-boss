import 'package:niagara_smart_drip_irrigation/features/reports/fert_live/fert_live_model.dart';

FertilizerLiveState fertilizerLiveStateFromRaw(
    Map<String, dynamic> raw,
    ) {
  final cM = raw['cM'] as String? ?? '';
  final cT = raw['cT'] as String? ?? 'NA';
  final cD = raw['cD'] as String? ?? 'NA';

  final cmstr = cM.split(',');

  // Motor Status Parsing
  final rawMotorStatus = cmstr.safe(0) ?? 'NA';
  final motorOn = rawMotorStatus == '1' || rawMotorStatus.toUpperCase().contains('ON');

  // If status is '0' or empty, we treat it as 'CYCLE COMPLETED' as per the UI requirement
  final motorStatus = (rawMotorStatus == '0' || rawMotorStatus == 'NA' || rawMotorStatus.isEmpty)
      ? "CYCLE COMPLETED"
      : rawMotorStatus;
  final motorStatuslive  = "${cmstr.safe(1)?.trim()}\n${cmstr.safe(2)?.trim()}";
  // RTC TIME (cmstr[1])
  final rtcTime = cmstr.safe(1)?.trim() ?? '0';

  // VRB & AMP (cmstr[2])
  final vrbAmp = cmstr.safe(2) ?? '';
  final vrb = int.tryParse(
    RegExp(r'VRB:(\d+)').firstMatch(vrbAmp)?.group(1) ?? '0',
  ) ??
      0;
  final amp = double.tryParse(
    RegExp(r'AMP:([\d.]+)').firstMatch(vrbAmp)?.group(1) ?? '0',
  ) ??
      0;

  // PRE & POST WATER
  final preWater = cmstr.safe(3)?.trim() ?? '00:00';
  final postWater = cmstr.safe(4)?.trim() ?? '00:00';

  // PROGRAM (cmstr[5])
  final program = cmstr.safe(5)?.trim() ?? '0';

  // MODE TYPE (Assuming cmstr[6])
  final modeType = cmstr.safe(6)?.trim() ?? 'TIMER FERT MODE';

  // PH / EC / PRESSURE (cmstr[7])
  final phecpressure = (cmstr.safe(7) ?? '0:0:0').split(':');
  final ph = double.tryParse(phecpressure.safe(0) ?? '0') ?? 0;
  final ec = double.tryParse(phecpressure.safe(1) ?? '0') ?? 0;
  final pressure = double.tryParse(phecpressure.safe(2) ?? '0') ?? 0;

  // FERTILIZER ON / OFF (cmstr[8])
  final fertOnOff = (cmstr.safe(8) ?? '0:0:0:0:0:0').split(':');
  final fertilizerActive = List.generate(6, (i) => fertOnOff.safe(i) != '0');

  // TANK LEVELS (cmstr[9])
  final tankStr = (cmstr.safe(9) ?? '0:0:0:0:0:0').split(':');
  final tankLevels = List.generate(
    6,
        (i) => int.tryParse(tankStr.safe(i) ?? '0') ?? 0,
  );

  // FERT RTC ON–OFF TIMES (cmstr[12] → cmstr[17])
  final List<String> setTimes = [];
  final List<String> remainTimes = [];

  for (int i = 0; i < 6; i++) {
    final rtc = cmstr.safe(12 + i)?.split(';') ?? const ['00:00', '00:00'];
    setTimes.add(rtc.safe(0) ?? "00:00");
    remainTimes.add(rtc.safe(1) ?? "00:00");
  }

  return FertilizerLiveState(
    lastSyncTime: cT,
    lastSyncDate: cD,
    program: program,
    rtcTime: rtcTime,
    motorOn: motorOn,
    motorStatus: motorStatus,
    motorStatuslive: motorStatuslive,
    vrb: vrb,
    amp: amp,
    preWater: preWater,
    postWater: postWater,
    modeType: modeType,
    fertilizerActive: fertilizerActive,
    tankLevels: tankLevels,
    ph: ph,
    ec: ec,
    pressure: pressure,
    setTimes: setTimes,
    remainTimes: remainTimes,
    fertLiters: List.generate(6, (i) => "0"),
  );
}

class FertilizerLiveState {
  final String lastSyncTime;
  final String lastSyncDate;
  final String program;
  final String rtcTime;
  final bool motorOn;
  final String motorStatus;
  final String motorStatuslive;
  final int vrb;
  final double amp;
  final String preWater;
  final String postWater;
  final String modeType;
  final List<bool> fertilizerActive;
  final List<int> tankLevels;
  final double ph;
  final double ec;
  final double pressure;
  final List<String> setTimes;
  final List<String> remainTimes;
  final List<String> fertLiters;

  FertilizerLiveState({
    required this.lastSyncTime,
    required this.lastSyncDate,
    required this.program,
    required this.rtcTime,
    required this.motorOn,
    required this.motorStatus,
    required this.motorStatuslive,
    required this.vrb,
    required this.amp,
    required this.preWater,
    required this.postWater,
    required this.modeType,
    required this.fertilizerActive,
    required this.tankLevels,
    required this.ph,
    required this.ec,
    required this.pressure,
    required this.setTimes,
    required this.remainTimes,
    required this.fertLiters,
  });
}
