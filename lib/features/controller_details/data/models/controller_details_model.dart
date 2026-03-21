
import '../../domain/entities/controller_details_entities.dart';

class ControllerResponseModel {
  final int code;
  final String message;
  final ControllerDetails controllerDetails;
  final List<GroupDetails> groupDetails;

  ControllerResponseModel({
    required this.code,
    required this.message,
    required this.controllerDetails,
    required this.groupDetails,
  });

  factory ControllerResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ControllerResponseModel(
      code: json['code'] ?? 0,
      message: json['message'] ?? '',
      controllerDetails: ControllerDetails.fromJson(data['controllerDetails'] ?? {}),
      groupDetails: (data['groupDetails'] as List<dynamic>? ?? [])
          .map((e) => GroupDetails.fromJson(e))
          .toList(),
    );
  }
}

class ControllerDetails extends ControllerDetailsEntities {
  ControllerDetails({
    required super.wpsIp,
    required super.wpsPort,
    required super.wapIp,
    required super.wapPort,
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
    required super.programName,
    required super.simNumber,
    required super.deviceName,
    required super.manualStatus,
    required super.dndStatus,
    required super.mobileCountryCode,
    required super.dealerId,
    required super.dealerName,
    required super.productId,
    required super.oldProductId,
    required super.userId,
    required super.userDeviceId,
    required super.dealerNumber,
    required super.dealerCountryCode,
    required super.deviceId,
    required super.productDesc,
    required super.dateOfManufacture,
    required super.warrentyMonths,
    required super.modelName,
    required super.modelId,
    required super.categoryName,
    required super.operationMode,
    required super.gprsMode,
    required super.appSmsMode,
    required super.groupName,
    required super.groupId,
    required super.serviceDealerId,
    required super.serviceDealerName,
    required super.serviceDealerCountryCode,
    required super.serviceDealerMobileNumber,
    required super.emailAddress,
    required super.cctvStatusFlag,
    required super.mobCctv,
    required super.webCctv,
    required super.customerName,
    required super.customerNumber,
    required super.customerCountryCode,
    required super.customerUserId,
  });

  factory ControllerDetails.fromJson(Map<String, dynamic> json) {
    return ControllerDetails(
      wpsIp: json['wpsIp']?.toString() ?? '',
      wpsPort: json['wpsPort']?.toString() ?? '',
      wapIp: json['wapIp']?.toString() ?? '',
      wapPort: json['wapPort']?.toString() ?? '',
      msgDesc: json['msgDesc']?.toString() ?? '',
      motorStatus: json['motorStatus']?.toString() ?? '',
      programNo: json['programNo']?.toString() ?? '',
      zoneNo: json['zoneNo']?.toString() ?? '',
      zoneRunTime: json['ZoneRunTime']?.toString() ?? '',
      zoneRemainingTime: json['zoneRemainingTime']?.toString() ?? '',
      menuId: json['menuId']?.toString() ?? '',
      referenceId: json['referenceId']?.toString() ?? '',
      setFlow: json['setFlow']?.toString() ?? '',
      remFlow: json['remFlow']?.toString() ?? '',
      flowRate: json['flowRate']?.toString() ?? '',
      programName: json['programName']?.toString() ?? '',
      simNumber: json['simNumber']?.toString() ?? '',
      deviceName: json['deviceName']?.toString() ?? '',
      manualStatus: json['manualStatus']?.toString() ?? '',
      dndStatus: json['dndStatus']?.toString() ?? '',
      mobileCountryCode: json['mobileCountryCode']?.toString() ?? '',
      dealerId: json['dealerId'] is int ? json['dealerId'] : int.tryParse(json['dealerId']?.toString() ?? '0') ?? 0,
      dealerName: json['dealerName']?.toString() ?? '',
      productId: json['productId'] is int ? json['productId'] : int.tryParse(json['productId']?.toString() ?? '0') ?? 0,
      oldProductId: json['oldProductId'] is int ? json['oldProductId'] : int.tryParse(json['oldProductId']?.toString() ?? '0') ?? 0,
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      userDeviceId: json['userDeviceId'] is int ? json['userDeviceId'] : int.tryParse(json['userDeviceId']?.toString() ?? '0') ?? 0,
      dealerNumber: json['dealerNumber']?.toString() ?? '',
      dealerCountryCode: json['dealerCountryCode']?.toString() ?? '',
      deviceId: json['deviceId']?.toString() ?? '',
      productDesc: json['productDesc']?.toString() ?? '',
      dateOfManufacture: json['dateOfManufacture']?.toString() ?? '',
      warrentyMonths: json['warrentyMonths'] is int ? json['warrentyMonths'] : int.tryParse(json['warrentyMonths']?.toString() ?? '0') ?? 0,
      modelName: json['modelName']?.toString() ?? '',
      modelId: json['model_Id'] is int ? json['model_Id'] : int.tryParse(json['model_Id']?.toString() ?? '0') ?? 0,
      categoryName: json['categoryName']?.toString() ?? '',
      operationMode: json['operationMode']?.toString() ?? '',
      gprsMode: json['gprsMode']?.toString() ?? '',
      appSmsMode: json['appSmsMode']?.toString() ?? '',
      groupName: json['groupName']?.toString() ?? '',
      groupId: json['groupId'] is int ? json['groupId'] : int.tryParse(json['groupId']?.toString() ?? '0') ?? 0,
      serviceDealerId: json['serviceDealerId'] is int ? json['serviceDealerId'] : int.tryParse(json['serviceDealerId']?.toString() ?? '0') ?? 0,
      serviceDealerName: json['serviceDealerName']?.toString() ?? '',
      serviceDealerCountryCode: json['serviceDealerCountryCode']?.toString() ?? '',
      serviceDealerMobileNumber: json['serviceDealerMobileNumber']?.toString() ?? '',
      emailAddress: json['emailAddress']?.toString() ?? '',
      cctvStatusFlag: json['cctvStatusFlag'] is int ? json['cctvStatusFlag'] : int.tryParse(json['cctvStatusFlag']?.toString() ?? '0') ?? 0,
      mobCctv: json['mobCctv']?.toString() ?? '',
      webCctv: json['webCctv']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerNumber: json['customerNumber']?.toString() ?? '',
      customerCountryCode: json['customerCountryCode']?.toString() ?? '',
      customerUserId: json['customerUserId'] is int ? json['customerUserId'] : int.tryParse(json['customerUserId']?.toString() ?? '0') ?? 0,
    );
  }
}

class GroupDetails {
  final int userGroupId;
  final int userId;
  final String groupName;

  GroupDetails({
    required this.userGroupId,
    required this.userId,
    required this.groupName,
  });

  factory GroupDetails.fromJson(Map<String, dynamic> json) {
    return GroupDetails(
      userGroupId: json['userGroupId'] is int ? json['userGroupId'] : int.tryParse(json['userGroupId']?.toString() ?? '0') ?? 0,
      userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '0') ?? 0,
      groupName: json['groupName']?.toString() ?? '',
    );
  }
}
