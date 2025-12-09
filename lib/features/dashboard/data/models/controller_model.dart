import 'package:equatable/equatable.dart';
import '../../data/dashboard_data.dart';
import '../../domain/dashboard_domain.dart';
// Add this import for jsonDecode

class ProgramModel extends ProgramEntity {
  const ProgramModel({
    required super.programId,
    required super.programNameDefault,
    required super.programName,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      programId: json['programId'] as int,
      programNameDefault: json['programNameDefault'] as String,
      programName: json['programName'] as String,
    );
  }
}

class ControllerModel extends Equatable implements ControllerEntity {
  @override
  final int userDeviceId;
  @override
  final String fertilizerMessage;
  @override
  final String filterMessage;
  @override
  final int userId;
  @override
  final String appSmsMode;
  @override
  final String status;
  @override
  final String ctrlStatusFlag;
  @override
  final String power;
  @override
  final String status1;
  @override
  final String msgcode;
  @override
  final String ctrlLatestMsg;
  @override
  final LiveMessageEntity liveMessage;
  @override
  final String relaystatus;
  @override
  final String operationMode;
  @override
  final String gprsMode;
  @override
  final String dndStatus;
  @override
  final String mobCctv;
  @override
  final String webCctv;
  @override
  final String simNumber;
  @override
  final String deviceName;
  @override
  final String deviceId;
  @override
  final int modelId;
  @override
  final String livesyncDate;
  @override
  final String livesyncTime;
  @override
  final List<ProgramEntity> programList;
  @override
  final String wpsIp;
  @override
  final String wpsPort;
  @override
  final String wapIp;
  @override
  final String wapPort;
  @override
  final String userProgramName;
  @override
  final String msgDesc;
  @override
  final String motorStatus;
  @override
  final String programNo;
  @override
  final String zoneNo;
  @override
  final String zoneRunTime;
  @override
  final String zoneRemainingTime;
  @override
  final String menuId;
  @override
  final String referenceId;
  @override
  final String setFlow;
  @override
  final String remFlow;
  @override
  final String flowRate;

  const ControllerModel({
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

  factory ControllerModel.fromJson(Map<String, dynamic> json) {
    // Parse programList
    List<ProgramEntity> parsedProgramList = [];
    if (json['programList'] != null && json['programList'] !is List<dynamic>) {
      final List<dynamic> programJsonList = json['programList'];
      parsedProgramList = programJsonList
          .map((programJson) => ProgramModel.fromJson(programJson))
          .toList();
    }

    // Parse liveMessage
    // print("liveMessage :: ${json['liveMessage']}");
    try {
    LiveMessageEntity parsedLiveMessage = LiveMessageModel.fromLiveMessage(json['liveMessage'] ?? {});
    } catch (e, sta) {
      print('Error ==> $e');
      print('Stack trace ==> $sta');
    }

    return ControllerModel(
      userDeviceId: json['userDeviceId'] as int? ?? 0,
      fertilizerMessage: json['fertilizerMessage'] as String? ?? '',
      filterMessage: json['filterMessage'] as String? ?? '',
      userId: json['userId'] as int? ?? 0,
      appSmsMode: json['appSmsMode'] as String? ?? '',
      status: json['status'] as String? ?? '',
      ctrlStatusFlag: json['ctrlStatusFlag'] as String? ?? '',
      power: json['Power'] as String? ?? '',
      status1: json['status1'] as String? ?? '',
      msgcode: json['msgcode'] as String? ?? '',
      ctrlLatestMsg: json['ctrlLatestMsg'] as String? ?? '',
      liveMessage: LiveMessageModel.fromLiveMessage(json['liveMessage']),
      relaystatus: json['relaystatus'] as String? ?? '',
      operationMode: json['operationMode'] as String? ?? '',
      gprsMode: json['gprsMode'] as String? ?? '',
      dndStatus: json['dndStatus'] as String? ?? '',
      mobCctv: json['mobCctv'] as String? ?? '',
      webCctv: json['webCctv'] as String? ?? '',
      simNumber: json['simNumber'] as String? ?? '',
      deviceName: json['deviceName'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      modelId: json['model_Id'] as int? ?? 0,
      livesyncDate: json['livesyncDate'] as String? ?? '',
      livesyncTime: json['livesyncTime'] as String? ?? '',
      programList: parsedProgramList,
      wpsIp: json['wpsIp'] as String? ?? '',
      wpsPort: json['wpsPort'] as String? ?? '',
      wapIp: json['wapIp'] as String? ?? '',
      wapPort: json['wapPort'] as String? ?? '',
      userProgramName: json['userProgramName'] as String? ?? '',
      msgDesc: json['msgDesc'] as String? ?? '',
      motorStatus: json['motorStatus'] as String? ?? '',
      programNo: json['programNo'] as String? ?? '',
      zoneNo: json['zoneNo'] as String? ?? '',
      zoneRunTime: json['ZoneRunTime'] as String? ?? '',
      zoneRemainingTime: json['zoneRemainingTime'] as String? ?? '',
      menuId: json['menuId'] as String? ?? '',
      referenceId: json['referenceId'] as String? ?? '',
      setFlow: json['setFlow'] as String? ?? '',
      remFlow: json['remFlow'] as String? ?? '',
      flowRate: json['flowRate'] as String? ?? '',
    );
  }

  ControllerModel copyWith({
    int? userDeviceId,
    String? fertilizerMessage,
    String? filterMessage,
    int? userId,
    String? appSmsMode,
    String? status,
    String? ctrlStatusFlag,
    String? power,
    String? status1,
    String? msgcode,
    String? ctrlLatestMsg,
    required LiveMessageEntity liveMessage,
    String? relaystatus,
    String? operationMode,
    String? gprsMode,
    String? dndStatus,
    String? mobCctv,
    String? webCctv,
    String? simNumber,
    String? deviceName,
    String? deviceId,
    int? modelId,
    String? livesyncDate,
    String? livesyncTime,
    List<ProgramEntity>? programList,
    String? wpsIp,
    String? wpsPort,
    String? wapIp,
    String? wapPort,
    String? userProgramName,
    String? msgDesc,
    String? motorStatus,
    String? programNo,
    String? zoneNo,
    String? zoneRunTime,
    String? zoneRemainingTime,
    String? menuId,
    String? referenceId,
    String? setFlow,
    String? remFlow,
    String? flowRate,
  }) {
    return ControllerModel(
      userDeviceId: userDeviceId ?? this.userDeviceId,
      fertilizerMessage: fertilizerMessage ?? this.fertilizerMessage,
      filterMessage: filterMessage ?? this.filterMessage,
      userId: userId ?? this.userId,
      appSmsMode: appSmsMode ?? this.appSmsMode,
      status: status ?? this.status,
      ctrlStatusFlag: ctrlStatusFlag ?? this.ctrlStatusFlag,
      power: power ?? this.power,
      status1: status1 ?? this.status1,
      msgcode: msgcode ?? this.msgcode,
      ctrlLatestMsg: ctrlLatestMsg ?? this.ctrlLatestMsg,
      liveMessage: liveMessage,
      relaystatus: relaystatus ?? this.relaystatus,
      operationMode: operationMode ?? this.operationMode,
      gprsMode: gprsMode ?? this.gprsMode,
      dndStatus: dndStatus ?? this.dndStatus,
      mobCctv: mobCctv ?? this.mobCctv,
      webCctv: webCctv ?? this.webCctv,
      simNumber: simNumber ?? this.simNumber,
      deviceName: deviceName ?? this.deviceName,
      deviceId: deviceId ?? this.deviceId,
      modelId: modelId ?? this.modelId,
      livesyncDate: livesyncDate ?? this.livesyncDate,
      livesyncTime: livesyncTime ?? this.livesyncTime,
      programList: programList ?? this.programList,
      wpsIp: wpsIp ?? this.wpsIp,
      wpsPort: wpsPort ?? this.wpsPort,
      wapIp: wapIp ?? this.wapIp,
      wapPort: wapPort ?? this.wapPort,
      userProgramName: userProgramName ?? this.userProgramName,
      msgDesc: msgDesc ?? this.msgDesc,
      motorStatus: motorStatus ?? this.motorStatus,
      programNo: programNo ?? this.programNo,
      zoneNo: zoneNo ?? this.zoneNo,
      zoneRunTime: zoneRunTime ?? this.zoneRunTime,
      zoneRemainingTime: zoneRemainingTime ?? this.zoneRemainingTime,
      menuId: menuId ?? this.menuId,
      referenceId: referenceId ?? this.referenceId,
      setFlow: setFlow ?? this.setFlow,
      remFlow: remFlow ?? this.remFlow,
      flowRate: flowRate ?? this.flowRate,
    );
  }

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