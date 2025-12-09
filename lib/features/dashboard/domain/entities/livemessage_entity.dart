import 'package:equatable/equatable.dart';

class LiveMessageEntity extends Equatable{
  final String motorOnOff;
  final String valveOnOff;
  final String liveDisplay1;
  final String liveDisplay2;
  final String rVoltage;
  final String yVoltage;
  final String bVoltage;
  final String ryVoltage;
  final String ybVoltage;
  final String brVoltage;
  final String rCurrent;
  final String yCurrent;
  final String bCurrent;
  final String phase;
  final String signal;
  final String batVolt;
  final String modeOfOperation;
  final String programName;
  final String zoneNo;
  final String valveForZone;
  final String zoneDuration;
  final String zoneRemainingTime;
  final String prsIn;
  final String prsOut;
  final String flowRate;
  final String wellLevel;
  final String wellPercent;
  final List<String> fertStatus;
  final String ec;
  final String ph;
  final String totalMeterFlow;
  final String runTimeToday;
  final String runTimePrevious;
  final String flowPrevDay;
  final String flowToday;
  final String moisture1;
  final String moisture2;
  final String energy;
  final String powerFactor;
  final List<String> fertValues; // f1–f6
  final String versionModule;
  final String versionBoard;

  const LiveMessageEntity({
    required this.motorOnOff,
    required this.valveOnOff,
    required this.liveDisplay1,
    required this.liveDisplay2,
    required this.rVoltage,
    required this.yVoltage,
    required this.bVoltage,
    required this.ryVoltage,
    required this.ybVoltage,
    required this.brVoltage,
    required this.rCurrent,
    required this.yCurrent,
    required this.bCurrent,
    required this.phase,
    required this.signal,
    required this.batVolt,
    required this.modeOfOperation,
    required this.programName,
    required this.zoneNo,
    required this.valveForZone,
    required this.zoneDuration,
    required this.zoneRemainingTime,
    required this.prsIn,
    required this.prsOut,
    required this.flowRate,
    required this.wellLevel,
    required this.wellPercent,
    required this.fertStatus,
    required this.ec,
    required this.ph,
    required this.totalMeterFlow,
    required this.runTimeToday,
    required this.runTimePrevious,
    required this.flowPrevDay,
    required this.flowToday,
    required this.moisture1,
    required this.moisture2,
    required this.energy,
    required this.powerFactor,
    required this.fertValues,
    required this.versionModule,
    required this.versionBoard,
  });

  @override
  // TODO: implement props
  List<Object?> get props => [
    motorOnOff,
    valveOnOff,
    liveDisplay1,
    liveDisplay2,
    rVoltage,
    yVoltage,
    bVoltage,
    ryVoltage,
    ybVoltage,
    brVoltage,
    rCurrent,
    yCurrent,
    bCurrent,
    phase,
    signal,
    batVolt,
    modeOfOperation,
    programName,
    zoneNo,
    valveForZone,
    zoneDuration,
    zoneRemainingTime,
    prsIn,
    prsOut,
    flowRate,
    wellLevel,
    wellPercent,
    fertStatus,
    ec,
    ph,
    totalMeterFlow,
    runTimeToday,
    runTimePrevious,
    flowPrevDay,
    flowToday,
    moisture1,
    moisture2,
    energy,
    powerFactor,
    fertValues,
    versionModule,
    versionBoard
  ];
}
