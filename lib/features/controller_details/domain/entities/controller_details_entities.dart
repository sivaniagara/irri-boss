import 'package:equatable/equatable.dart';

class ControllerDetailsEntities extends Equatable {
  final String wpsIp;
  final String wpsPort;
  final String wapIp;
  final String wapPort;
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
  final String programName;
  final String simNumber;
  final String deviceName;
  final String manualStatus;
  final String dndStatus;
  final String mobileCountryCode;
  final int dealerId;
  final String dealerName;
  final int productId;
  final int oldProductId;
  final int userId;
  final int userDeviceId;
  final String dealerNumber;
  final String dealerCountryCode;
  final String deviceId;
  final String productDesc;
  final String dateOfManufacture;
  final int warrentyMonths;
  final String modelName;
  final int modelId;
  final String categoryName;
  final String operationMode;
  final String gprsMode;
  final String appSmsMode;
  final String groupName;
  final int groupId;
  final int serviceDealerId;
  final String serviceDealerName;
  final String serviceDealerCountryCode;
  final String serviceDealerMobileNumber;
  final String emailAddress;
  final int cctvStatusFlag;
  final String mobCctv;
  final String webCctv;
  final String customerName;
  final String customerNumber;
  final String customerCountryCode;
  final int customerUserId;

  const ControllerDetailsEntities({
    required this.wpsIp,
    required this.wpsPort,
    required this.wapIp,
    required this.wapPort,
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
    required this.programName,
    required this.simNumber,
    required this.deviceName,
    required this.manualStatus,
    required this.dndStatus,
    required this.mobileCountryCode,
    required this.dealerId,
    required this.dealerName,
    required this.productId,
    required this.oldProductId,
    required this.userId,
    required this.userDeviceId,
    required this.dealerNumber,
    required this.dealerCountryCode,
    required this.deviceId,
    required this.productDesc,
    required this.dateOfManufacture,
    required this.warrentyMonths,
    required this.modelName,
    required this.modelId,
    required this.categoryName,
    required this.operationMode,
    required this.gprsMode,
    required this.appSmsMode,
    required this.groupName,
    required this.groupId,
    required this.serviceDealerId,
    required this.serviceDealerName,
    required this.serviceDealerCountryCode,
    required this.serviceDealerMobileNumber,
    required this.emailAddress,
    required this.cctvStatusFlag,
    required this.mobCctv,
    required this.webCctv,
    required this.customerName,
    required this.customerNumber,
    required this.customerCountryCode,
    required this.customerUserId,
  });

  @override
  List<Object?> get props => [
    wpsIp,
    wpsPort,
    wapIp,
    wapPort,
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
    programName,
    simNumber,
    deviceName,
    manualStatus,
    dndStatus,
    mobileCountryCode,
    dealerId,
    dealerName,
    productId,
    oldProductId,
    userId,
    userDeviceId,
    dealerNumber,
    dealerCountryCode,
    deviceId,
    productDesc,
    dateOfManufacture,
    warrentyMonths,
    modelName,
    modelId,
    categoryName,
    operationMode,
    gprsMode,
    appSmsMode,
    groupName,
    groupId,
    serviceDealerId,
    serviceDealerName,
    serviceDealerCountryCode,
    serviceDealerMobileNumber,
    emailAddress,
    cctvStatusFlag,
    mobCctv,
    webCctv,
    customerName,
    customerNumber,
    customerCountryCode,
    customerUserId,
  ];
}
