
import 'package:equatable/equatable.dart';

import 'livemessage_entity.dart';

class ProgramEntity extends Equatable {
  final int programId;
  final String programNameDefault;
  final String programName;

  const ProgramEntity({
    required this.programId,
    required this.programNameDefault,
    required this.programName,
  });

  @override
  List<Object> get props => [programId, programNameDefault, programName];
}

class ControllerEntity extends Equatable {
  final int userDeviceId;
  final String fertilizerMessage;
  final String filterMessage;
  final int userId;
  final String appSmsMode;
  final String status;
  final String ctrlStatusFlag;
  final String power;
  final String status1;
  final String msgcode;
  final String ctrlLatestMsg;
  final LiveMessageEntity liveMessage;
  final String relaystatus;
  final String operationMode;
  final String gprsMode;
  final String dndStatus;
  final String mobCctv;
  final String webCctv;
  final String simNumber;
  final String deviceName;
  final String deviceId;
  final int modelId;
  final String livesyncDate;
  final String livesyncTime;
  final List<ProgramEntity> programList;
  final String wpsIp;
  final String wpsPort;
  final String wapIp;
  final String wapPort;
  final String userProgramName;
  final String msgDesc;
  final String motorStatus;
  final String programNo;
  final String zoneNo;
  final String zoneRunTime;
  final String zoneRemainingTime;
  final String menuId;
  final String referenceId;
  final String setFlow;
  final String remFlow;
  final String flowRate;

  const ControllerEntity({
    required this.userDeviceId,
    required this.fertilizerMessage,
    required this.filterMessage,
    required this.userId,
    required this.appSmsMode,
    required this.status,
    required this.ctrlStatusFlag,
    required this.power,
    required this.status1,
    required this.msgcode,
    required this.ctrlLatestMsg,
    required this.liveMessage,
    required this.relaystatus,
    required this.operationMode,
    required this.gprsMode,
    required this.dndStatus,
    required this.mobCctv,
    required this.webCctv,
    required this.simNumber,
    required this.deviceName,
    required this.deviceId,
    required this.modelId,
    required this.livesyncDate,
    required this.livesyncTime,
    required this.programList,
    required this.wpsIp,
    required this.wpsPort,
    required this.wapIp,
    required this.wapPort,
    required this.userProgramName,
    required this.msgDesc,
    required this.motorStatus,
    required this.programNo,
    required this.zoneNo,
    required this.zoneRunTime,
    required this.zoneRemainingTime,
    required this.menuId,
    required this.referenceId,
    required this.setFlow,
    required this.remFlow,
    required this.flowRate,
  });

  @override
  List<Object?> get props => [
    userDeviceId,
    fertilizerMessage,
    filterMessage,
    userId,
    appSmsMode,
    status,
    ctrlStatusFlag,
    power,
    status1,
    msgcode,
    ctrlLatestMsg,
    liveMessage,
    relaystatus,
    operationMode,
    gprsMode,
    dndStatus,
    mobCctv,
    webCctv,
    simNumber,
    deviceName,
    deviceId,
    modelId,
    livesyncDate,
    livesyncTime,
    programList,
    wpsIp,
    wpsPort,
    wapIp,
    wapPort,
    userProgramName,
    msgDesc,
    motorStatus,
    programNo,
    zoneNo,
    zoneRunTime,
    zoneRemainingTime,
    menuId,
    referenceId,
    setFlow,
    remFlow,
    flowRate,
  ];
}

