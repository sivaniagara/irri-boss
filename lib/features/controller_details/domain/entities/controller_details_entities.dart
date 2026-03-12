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
  List<Object?> get props =>
      [
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


  ControllerDetailsEntities copyWith({
    String? wpsIp,
    String? wpsPort,
    String? wapIp,
    String? wapPort,
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
    String? programName,
    String? simNumber,
    String? deviceName,
    String? manualStatus,
    String? dndStatus,
    String? mobileCountryCode,
    int? dealerId,
    String? dealerName,
    int? productId,
    int? oldProductId,
    int? userId,
    int? userDeviceId,
    String? dealerNumber,
    String? dealerCountryCode,
    String? deviceId,
    String? productDesc,
    String? dateOfManufacture,
    int? warrentyMonths,
    String? modelName,
    int? modelId,
    String? categoryName,
    String? operationMode,
    String? gprsMode,
    String? appSmsMode,
    String? groupName,
    int? groupId,
    int? serviceDealerId,
    String? serviceDealerName,
    String? serviceDealerCountryCode,
    String? serviceDealerMobileNumber,
    String? emailAddress,
    int? cctvStatusFlag,
    String? mobCctv,
    String? webCctv,
    String? customerName,
    String? customerNumber,
    String? customerCountryCode,
    int? customerUserId,
  }) {
    return ControllerDetailsEntities(
      wpsIp: wpsIp ?? this.wpsIp,
      wpsPort: wpsPort ?? this.wpsPort,
      wapIp: wapIp ?? this.wapIp,
      wapPort: wapPort ?? this.wapPort,
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
      programName: programName ?? this.programName,
      simNumber: simNumber ?? this.simNumber,
      deviceName: deviceName ?? this.deviceName,
      manualStatus: manualStatus ?? this.manualStatus,
      dndStatus: dndStatus ?? this.dndStatus,
      mobileCountryCode: mobileCountryCode ?? this.mobileCountryCode,
      dealerId: dealerId ?? this.dealerId,
      dealerName: dealerName ?? this.dealerName,
      productId: productId ?? this.productId,
      oldProductId: oldProductId ?? this.oldProductId,
      userId: userId ?? this.userId,
      userDeviceId: userDeviceId ?? this.userDeviceId,
      dealerNumber: dealerNumber ?? this.dealerNumber,
      dealerCountryCode: dealerCountryCode ?? this.dealerCountryCode,
      deviceId: deviceId ?? this.deviceId,
      productDesc: productDesc ?? this.productDesc,
      dateOfManufacture: dateOfManufacture ?? this.dateOfManufacture,
      warrentyMonths: warrentyMonths ?? this.warrentyMonths,
      modelName: modelName ?? this.modelName,
      modelId: modelId ?? this.modelId,
      categoryName: categoryName ?? this.categoryName,
      operationMode: operationMode ?? this.operationMode,
      gprsMode: gprsMode ?? this.gprsMode,
      appSmsMode: appSmsMode ?? this.appSmsMode,
      groupName: groupName ?? this.groupName,
      groupId: groupId ?? this.groupId,
      serviceDealerId: serviceDealerId ?? this.serviceDealerId,
      serviceDealerName: serviceDealerName ?? this.serviceDealerName,
      serviceDealerCountryCode:
      serviceDealerCountryCode ?? this.serviceDealerCountryCode,
      serviceDealerMobileNumber:
      serviceDealerMobileNumber ?? this.serviceDealerMobileNumber,
      emailAddress: emailAddress ?? this.emailAddress,
      cctvStatusFlag: cctvStatusFlag ?? this.cctvStatusFlag,
      mobCctv: mobCctv ?? this.mobCctv,
      webCctv: webCctv ?? this.webCctv,
      customerName: customerName ?? this.customerName,
      customerNumber: customerNumber ?? this.customerNumber,
      customerCountryCode: customerCountryCode ?? this.customerCountryCode,
      customerUserId: customerUserId ?? this.customerUserId,
    );
  }
}