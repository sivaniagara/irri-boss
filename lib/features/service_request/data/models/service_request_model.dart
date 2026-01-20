import '../../domain/entities/service_request_entity.dart';

class ServiceRequestModel extends ServiceRequestEntity {
  ServiceRequestModel({
    required super.userName,
    required super.mobileNumber,
    required super.countryCode,
    required super.serviceDesc,
    required super.deviceName,
    required super.serviceStatus,
    required super.serviceRequestId,
    required super.date,
    required super.time,
    required super.userDeviceId,
    required super.qrCode,
    required super.dealerId,
    required super.dealerName,
    required super.userId,
    required super.inProgDate,
    required super.inProgTime,
    required super.closedDate,
    required super.closedTime,
    required super.inProgUser,
    required super.closedUser,
    required super.inProgRemark,
    required super.closedRemark,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      userName: json['userName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      countryCode: json['countryCode'] ?? '',
      serviceDesc: json['serviceDesc'] ?? '',
      deviceName: json['deviceName'] ?? '',
      serviceStatus: json['serviceStatus']?.toString() ?? '',
      serviceRequestId: json['serviceRequestId'] ?? 0,
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      userDeviceId: json['userDeviceId'] ?? 0,
      qrCode: json['QRCode'] ?? '',
      dealerId: json['dealerId'] ?? 0,
      dealerName: json['dealerName'] ?? '',
      userId: json['userId'] ?? 0,
      inProgDate: json['inProgDate'] ?? '',
      inProgTime: json['inProgTime'] ?? '',
      closedDate: json['closedDate'] ?? '',
      closedTime: json['closedTime'] ?? '',
      inProgUser: json['inProgUser'] ?? '',
      closedUser: json['closedUser'] ?? '',
      inProgRemark: json['inProgRemark'] ?? '',
      closedRemark: json['closedRemark'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'mobileNumber': mobileNumber,
      'countryCode': countryCode,
      'serviceDesc': serviceDesc,
      'deviceName': deviceName,
      'serviceStatus': serviceStatus,
      'serviceRequestId': serviceRequestId,
      'date': date,
      'time': time,
      'userDeviceId': userDeviceId,
      'QRCode': qrCode,
      'dealerId': dealerId,
      'dealerName': dealerName,
      'userId': userId,
      'inProgDate': inProgDate,
      'inProgTime': inProgTime,
      'closedDate': closedDate,
      'closedTime': closedTime,
      'inProgUser': inProgUser,
      'closedUser': closedUser,
      'inProgRemark': inProgRemark,
      'closedRemark': closedRemark,
    };
  }
}
