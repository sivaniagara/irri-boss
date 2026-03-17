import 'package:niagara_smart_drip_irrigation/features/reports/fert_live/fert_live_model.dart';

FertilizerLiveState fertilizerLiveStateFromRaw(
    Map<String, dynamic> raw,
    ) {
  final cM = raw['cM'] as String? ?? '';
  final cT = raw['cT'] as String? ?? 'NA';
  final cD = raw['cD'] as String? ?? 'NA';

  final cmstr = cM.split(',');

  // Check if it's an LD01/LD06 type live message based on length
  // Provided sample has ~45-50 parts
  bool isLiveMsg = cmstr.length > 30;

  if (isLiveMsg) {
    // LD01/LD06 Live Message Structure
    final motorOn = cmstr.safe(0) == '1';
    final motorStatus = cmstr.safe(3)?.trim() ?? 'NA';
    final motorStatuslive = cmstr.safe(4)?.trim() ?? '';
    
    final preWater = cmstr.safe(18)?.trim() ?? '00:00';
    final postWater = cmstr.safe(19)?.trim() ?? '00:00';
    final program = cmstr.safe(15)?.trim() ?? '0';
    final modeType = cmstr.safe(14)?.trim() ?? 'TIMER MODE';

    // PH / EC / Pressure packed differently in LD01
    // Sample: ...0.0,0.0,0.0,0.00F-00... (Indices 20, 21, 22)
    final pressure = double.tryParse(cmstr.safe(20) ?? '0') ?? 0; // prsIn
    final ec = double.tryParse(cmstr.safe(25)?.split(':').safe(0) ?? '0') ?? 0;
    final ph = double.tryParse(cmstr.safe(25)?.split(':').safe(1) ?? '0') ?? 0;

    // FERTILIZER ON / OFF (Index 24)
    final fertOnOff = (cmstr.safe(24) ?? '0:0:0:0:0:0').split(':');
    final fertilizerActive = List.generate(6, (i) {
      final val = fertOnOff.safe(i) ?? '0';
      return val.endsWith('1');
    });

    // Tank Levels (Index 36 for LD01 fert values)
    final fertVals = (cmstr.safe(36) ?? '0;0;0;0:0:0').split(';');
    final tankLevels = List.generate(6, (i) {
      final val = fertVals.safe(i) ?? '0';
      return (double.tryParse(val) ?? 0).toInt();
    });

    return FertilizerLiveState(
      lastSyncTime: cT,
      lastSyncDate: cD,
      program: program,
      rtcTime: cT,
      motorOn: motorOn,
      motorStatus: motorStatus,
      motorStatuslive: motorStatuslive,
      vrb: 0,
      amp: double.tryParse(cmstr.safe(11) ?? '0') ?? 0,
      preWater: preWater,
      postWater: postWater,
      modeType: modeType,
      fertilizerActive: fertilizerActive,
      tankLevels: tankLevels,
      ph: ph,
      ec: ec,
      pressure: pressure,
      setTimes: List.generate(6, (_) => "00:00"), // Not explicitly in LD01 simple live
      remainTimes: List.generate(6, (_) => "00:00"),
      fertLiters: fertVals,
    );
  } else {
    // Original LD02 Fertilizer specific message logic
    final rawMotorStatus = cmstr.safe(0) ?? 'NA';
    final motorStatusLine1 = cmstr.safe(1)?.trim() ?? '';
    final motorStatusLine2 = cmstr.safe(2)?.trim() ?? '';

    final motorOn = rawMotorStatus == '1' ||
        rawMotorStatus.toUpperCase().contains('ON') ||
        motorStatusLine1.toUpperCase().contains('ON');

    final motorStatus = (rawMotorStatus == '0' || rawMotorStatus == 'NA' || rawMotorStatus.isEmpty)
        ? "CYCLE COMPLETED"
        : rawMotorStatus;

    final motorStatuslive = "$motorStatusLine1\n$motorStatusLine2";
    final preWater = cmstr.safe(3)?.trim() ?? '00:00';
    final postWater = cmstr.safe(4)?.trim() ?? '00:00';
    final program = cmstr.safe(5)?.trim() ?? '0';
    final modeType = cmstr.safe(6)?.trim() ?? 'TIMER FERT MODE';

    final phecpressure = (cmstr.safe(7) ?? '0:0:0').split(':');
    final ph = double.tryParse(phecpressure.safe(0) ?? '0') ?? 0;
    final ec = double.tryParse(phecpressure.safe(1) ?? '0') ?? 0;
    final pressure = double.tryParse(phecpressure.safe(2) ?? '0') ?? 0;

    final fertOnOff = (cmstr.safe(8) ?? '0:0:0:0:0:0').split(':');
    final fertilizerActive = List.generate(6, (i) {
      final val = fertOnOff.safe(i) ?? '0';
      return val.endsWith('1');
    });

    final tankStr = (cmstr.safe(9) ?? '0:0:0:0:0:0').split(':');
    final tankLevels = List.generate(6, (i) => (double.tryParse(tankStr.safe(i) ?? '0') ?? 0).toInt());

    final litersData = (cmstr.safe(11) ?? '').split(';');
    final fertLiters = List.generate(6, (i) {
      final values = litersData.safe(i)?.split(':') ?? [];
      return values.safe(0) ?? "0";
    });

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
      rtcTime: cT,
      motorOn: motorOn,
      motorStatus: motorStatus,
      motorStatuslive: motorStatuslive,
      vrb: 0,
      amp: 0,
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
      fertLiters: fertLiters,
    );
  }
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
