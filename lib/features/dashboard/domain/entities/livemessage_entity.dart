import 'package:equatable/equatable.dart';

class LiveMessageEntity extends Equatable {
  final String cd;
  final String ct;
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
  final String lastsync;
  final String fullMessage;
  final String msgDesc;

  const LiveMessageEntity({
    required this.cd,
    required this.ct,
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
    required this.lastsync,
    this.fullMessage = '',
    this.msgDesc = '',
  });

  @override
  List<Object?> get props => [
    cd,
    ct,
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
    versionBoard,
    lastsync,
    fullMessage,
    msgDesc,
  ];

  LiveMessageEntity copyWith({
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
    return LiveMessageEntity(
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
