
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
      wpsIp: json['wpsIp'] ?? '',
      wpsPort: json['wpsPort'] ?? '',
      wapIp: json['wapIp'] ?? '',
      wapPort: json['wapPort'] ?? '',
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
      programName: json['programName'] ?? '',
      simNumber: json['simNumber'] ?? '',
      deviceName: json['deviceName'] ?? '',
      manualStatus: json['manualStatus'] ?? '',
      dndStatus: json['dndStatus'] ?? '',
      mobileCountryCode: json['mobileCountryCode'] ?? '',
      dealerId: json['dealerId'] ?? 0,
      dealerName: json['dealerName'] ?? '',
      productId: json['productId'] ?? 0,
      oldProductId: json['oldProductId'] ?? 0,
      userId: json['userId'] ?? 0,
      userDeviceId: json['userDeviceId'] ?? 0,
      dealerNumber: json['dealerNumber'] ?? '',
      dealerCountryCode: json['dealerCountryCode'] ?? '',
      deviceId: json['deviceId'] ?? '',
      productDesc: json['productDesc'] ?? '',
      dateOfManufacture: json['dateOfManufacture'] ?? '',
      warrentyMonths: json['warrentyMonths'] ?? 0,
      modelName: json['modelName'] ?? '',
      modelId: json['model_Id'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      operationMode: json['operationMode'] ?? '',
      gprsMode: json['gprsMode'] ?? '',
      appSmsMode: json['appSmsMode'] ?? '',
      groupName: json['groupName'] ?? '',
      groupId: json['groupId'] ?? 0,
      serviceDealerId: json['serviceDealerId'] ?? 0,
      serviceDealerName: json['serviceDealerName'] ?? '',
      serviceDealerCountryCode: json['serviceDealerCountryCode'] ?? '',
      serviceDealerMobileNumber: json['serviceDealerMobileNumber'] ?? '',
      emailAddress: json['emailAddress'] ?? '',
      cctvStatusFlag: json['cctvStatusFlag'] ?? 0,
      mobCctv: json['mobCctv'] ?? '',
      webCctv: json['webCctv'] ?? '',
      customerName: json['customerName'] ?? '',
      customerNumber: json['customerNumber'] ?? '',
      customerCountryCode: json['customerCountryCode'] ?? '',
      customerUserId: json['customerUserId'] ?? 0,
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
      userGroupId: json['userGroupId'] ?? 0,
      userId: json['userId'] ?? 0,
      groupName: json['groupName'] ?? '',
    );
  }
}
