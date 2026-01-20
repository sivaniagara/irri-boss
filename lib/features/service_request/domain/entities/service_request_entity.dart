class ServiceRequestEntity {
  final String userName;
  final String mobileNumber;
  final String countryCode;
  final String serviceDesc;
  final String deviceName;
  final String serviceStatus;
  final int serviceRequestId;
  final String date;
  final String time;
  final int userDeviceId;
  final String qrCode;
  final int dealerId;
  final String dealerName;
  final int userId;
  final String inProgDate;
  final String inProgTime;
  final String closedDate;
  final String closedTime;
  final String inProgUser;
  final String closedUser;
  final String inProgRemark;
  final String closedRemark;

  ServiceRequestEntity({
    required this.userName,
    required this.mobileNumber,
    required this.countryCode,
    required this.serviceDesc,
    required this.deviceName,
    required this.serviceStatus,
    required this.serviceRequestId,
    required this.date,
    required this.time,
    required this.userDeviceId,
    required this.qrCode,
    required this.dealerId,
    required this.dealerName,
    required this.userId,
    required this.inProgDate,
    required this.inProgTime,
    required this.closedDate,
    required this.closedTime,
    required this.inProgUser,
    required this.closedUser,
    required this.inProgRemark,
    required this.closedRemark,
  });
}
