import 'package:niagara_smart_drip_irrigation/features/reports/fert_live/fert_live_model.dart';

FertilizerLiveState fertilizerLiveStateFromRaw(
    Map<String, dynamic> raw,
    ) {
  final cM = raw['cM'] as String? ?? '';
  final cT = raw['cT'] as String? ?? 'NA';
  final cD = raw['cD'] as String? ?? 'NA';

  final cmstr = cM.split(',');

  // MOTOR ON / OFF (same logic as Swift)
  final motorOn =
  !(cmstr.contains('OFF') || cmstr.contains('NO SUPPLY'));

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

  // PROGRAM (cmstr[5])
  final program = cmstr.safe(5)?.trim() ?? '0';

  // PH / EC / PRESSURE (cmstr[7])
  final phecpressure =
  (cmstr.safe(7) ?? '0:0:0').split(':');
  final ph = double.tryParse(phecpressure.safe(0) ?? '0') ?? 0;
  final ec = double.tryParse(phecpressure.safe(1) ?? '0') ?? 0;
  final pressure =
      double.tryParse(phecpressure.safe(2) ?? '0') ?? 0;

  // FERTILIZER ON / OFF (cmstr[8])
  final fertOnOff =
  (cmstr.safe(8) ?? '0:0:0:0:0:0').split(':');
  final fertilizerActive =
  List.generate(6, (i) => fertOnOff.safe(i) != '0');

  // TANK LEVELS (using venture animation values cmstr[9])
  final tankStr =
  (cmstr.safe(9) ?? '0:0:0:0:0:0').split(':');
  final tankLevels = List.generate(
    6,
        (i) => int.tryParse(tankStr.safe(i) ?? '0') ?? 0,
  );

  // FERTILIZER LITERS / RATE (cmstr[10])
  final fertRate =
  (cmstr.safe(10) ?? '0:0:0:0:0:0').split(':');
  final fertLiters =
  List.generate(6, (i) => fertRate.safe(i) ?? '0');

  // FERT RTC ON–OFF TIMES (cmstr[12] → cmstr[17])
  final fertTimes = List.generate(6, (i) {
    final rtc =
        cmstr.safe(12 + i)?.split(';') ?? const ['00:00', '00:00'];
    return '${rtc.safe(0) ?? "00:00"} - ${rtc.safe(1) ?? "00:00"}';
  });

  return FertilizerLiveState(
    lastSyncTime: cT,
    lastSyncDate: cD,
    program: program,
    rtcTime: rtcTime,
    motorOn: motorOn,
    vrb: vrb,
    amp: amp,
    fertilizerActive: fertilizerActive,
    tankLevels: tankLevels,
    ph: ph,
    ec: ec,
    pressure: pressure,
    fertTimes: fertTimes,
    fertLiters: fertLiters,
  );
}

class FertilizerLiveState {
  final String lastSyncTime;
  final String lastSyncDate;
  final String program;
  final String rtcTime;
  final bool motorOn;
  final int vrb;
  final double amp;

  final List<bool> fertilizerActive; // F1–F6
  final List<int> tankLevels; // 0–1000

  final double ph;
  final double ec;
  final double pressure;

  final List<String> fertTimes;
  final List<String> fertLiters;

  FertilizerLiveState({
    required this.lastSyncTime,
    required this.lastSyncDate,
    required this.program,
    required this.rtcTime,
    required this.motorOn,
    required this.vrb,
    required this.amp,
    required this.fertilizerActive,
    required this.tankLevels,
    required this.ph,
    required this.ec,
    required this.pressure,
    required this.fertTimes,
    required this.fertLiters,
  });
}
