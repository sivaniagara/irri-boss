import '../../domain/entities/controller_entity.dart';
import '../../domain/entities/livemessage_entity.dart';
import '../../presentation/helper/get_sms_sync.dart';
import 'live_message_model.dart';

class ProgramModel extends ProgramEntity {
  const ProgramModel({
    required super.programId,
    required super.programName,
    required super.programNameDefault,
    required super.listOfZone,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    print("json ====> ${json}");
    return ProgramModel(
      programId: json['programId'] as int? ?? 0,
      programName: json['programName'] as String? ?? '',
      programNameDefault: json['programNameDefault'] as String? ?? '',
      listOfZone: json['zones'].map<ZoneEntity>((e) => ZoneEntity(zoneNumber: e['zoneNumber'])).toList(),
    );
  }
}
class ControllerModel extends ControllerEntity {
  const ControllerModel({
    required super.userDeviceId,
    required super.fertilizerMessage,
    required super.filterMessage,
    required super.userId,
    required super.appSmsMode,
    required super.status,
    required super.ctrlStatusFlag,
    required super.power,
    required super.status1,
    required super.msgcode,
    required super.ctrlLatestMsg,
    required super.liveMessage,
    required super.relaystatus,
    required super.operationMode,
    required super.gprsMode,
    required super.dndStatus,
    required super.mobCctv,
    required super.webCctv,
    required super.simNumber,
    required super.deviceName,
    required super.deviceId,
    required super.modelId,
    required super.livesyncDate,
    required super.livesyncTime,
    required super.smsSyncTime,
    required super.programList,
    required super.wpsIp,
    required super.wpsPort,
    required super.wapIp,
    required super.wapPort,
    required super.userProgramName,
    required super.msgDesc,
    required super.motorStatus,
    required super.programNo,
    required super.zoneNo,
    required super.zoneRunTime,
    required super.zoneRemainingTime,
    required super.menuId,
    required super.referenceId,
    required super.setFlow,
    required super.remFlow,
    required super.flowRate,
  });

  factory ControllerModel.fromJson(Map<String, dynamic> json) {
    final List<ProgramEntity> programs = json['programList'] is List
        ? (json['programList'] as List).map((e) => ProgramModel.fromJson(e)).toList()
        : const [];

    final rawDate = json['livesyncDate']?.toString() ?? '';
    final rawTime = json['livesyncTime']?.toString() ?? '';
    final formattedDateTime = _formatSync(rawDate, rawTime);

    final String latestMsg = json['ctrlLatestMsg']?.toString() ?? '';
    final String parsedSmsSync = getSmsSync(latestMsg);

    final LiveMessageEntity liveMessage = LiveMessageModel.fromLiveMessage(
      json['liveMessage']?.toString() ?? '',
      externalLastSync: formattedDateTime,
    );

    return ControllerModel(
      userDeviceId: json['userDeviceId'] ?? 0,
      fertilizerMessage: json['fertilizerMessage'] ?? '',
      filterMessage: json['filterMessage'] ?? '',
      userId: json['userId'] ?? 0,
      appSmsMode: json['appSmsMode'] ?? '',
      status: json['status'] ?? '',
      ctrlStatusFlag: json['ctrlStatusFlag'] ?? '',
      power: json['Power'] ?? '',
      status1: json['status1'] ?? '',
      msgcode: json['msgcode'] ?? '',
      ctrlLatestMsg: latestMsg,
      liveMessage: liveMessage,
      relaystatus: json['relaystatus'] ?? '',
      operationMode: json['operationMode'] ?? '',
      gprsMode: json['gprsMode'] ?? '',
      dndStatus: json['dndStatus'] ?? '',
      mobCctv: json['mobCctv'] ?? '',
      webCctv: json['webCctv'] ?? '',
      simNumber: json['simNumber'] ?? '',
      deviceName: json['deviceName'] ?? '',
      deviceId: json['deviceId'] ?? '',
      modelId: json['model_Id'] ?? 0,
      livesyncDate: formattedDateTime.split('\n').last,
      livesyncTime: formattedDateTime.split('\n').first,
      smsSyncTime: parsedSmsSync.isNotEmpty ? parsedSmsSync : '--',
      programList: programs,
      wpsIp: json['wpsIp'] ?? '',
      wpsPort: json['wpsPort'] ?? '',
      wapIp: json['wapIp'] ?? '',
      wapPort: json['wapPort'] ?? '',
      userProgramName: json['userProgramName'] ?? '',
      msgDesc: json['msgDesc'] ?? '',
      motorStatus: json['motorStatus'] ?? '',
      programNo: json['programNo'] ?? '',
      zoneNo: json['zoneNo'] ?? '',
      zoneRunTime: json['ZoneRunTime'] ?? '',
      zoneRemainingTime: json['zoneRemainingTime'] ?? '',
      menuId: json['menuId'] ?? '',
      referenceId: json['referenceId'] ?? '',
      setFlow: json['setFlow'] ?? '',
      remFlow: json['remFlow'] ?? '',
      flowRate: json['flowRate'] ?? '',
    );
  }

  static String _formatSync(String rawDate, String rawTime) {
    if (rawDate.isEmpty || rawTime.isEmpty) return "--\n--";
    return "$rawTime\n$rawDate";
  }

  @override
  ControllerModel copyWith({
    LiveMessageEntity? liveMessage,
    String? motorStatus,
    String? flowRate,
    List<ProgramEntity>? programList,
     String? livesyncDate,
    String? livesyncTime,
    String? smsSyncTime,
    String? status,
   }) {
    return ControllerModel(
      userDeviceId: userDeviceId,
      fertilizerMessage: fertilizerMessage,
      filterMessage: filterMessage,
      userId: userId,
      appSmsMode: appSmsMode,
      status: status ?? this.status,
      ctrlStatusFlag: ctrlStatusFlag,
      power: power,
      status1: status1,
      msgcode: msgcode,
      ctrlLatestMsg: ctrlLatestMsg ?? this.ctrlLatestMsg,
      liveMessage: liveMessage ?? this.liveMessage,
      relaystatus: relaystatus,
      operationMode: operationMode,
      gprsMode: gprsMode,
      dndStatus: dndStatus,
      mobCctv: mobCctv,
      webCctv: webCctv,
      simNumber: simNumber,
      deviceName: deviceName,
      deviceId: deviceId,
      modelId: modelId,
      livesyncDate: livesyncDate ?? this.livesyncDate,
      livesyncTime: livesyncTime ?? this.livesyncTime,
      smsSyncTime: smsSyncTime ?? this.smsSyncTime,
      programList: programList ?? this.programList,
      wpsIp: wpsIp,
      wpsPort: wpsPort,
      wapIp: wapIp,
      wapPort: wapPort,
      userProgramName: userProgramName,
      msgDesc: msgDesc ?? this.msgDesc,
      motorStatus: motorStatus ?? this.motorStatus,
      programNo: programNo,
      zoneNo: zoneNo,
      zoneRunTime: zoneRunTime,
      zoneRemainingTime: zoneRemainingTime,
      menuId: menuId,
      referenceId: referenceId,
      setFlow: setFlow,
      remFlow: remFlow,
      flowRate: flowRate ?? this.flowRate,
    );
  }
}
