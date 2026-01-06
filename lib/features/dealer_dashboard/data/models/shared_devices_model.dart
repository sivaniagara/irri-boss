import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/domain/entities/shared_devices_entity.dart';

class SharedDevicesModel extends SharedDevicesEntity {
  SharedDevicesModel({
    required super.userName,
    required super.userId,
    required super.shareUserId,
    required super.controllerId,
    required super.userDeviceId,
    required super.groupId,
    required super.groupName,
    required super.deviceName,
    required super.deviceId
  });

  factory SharedDevicesModel.fromJson(Map<String, dynamic> json) {
    return SharedDevicesModel(
        userName: json["userName"],
        userId: json["userId"],
        shareUserId: json["shareUserId"],
        controllerId: json["controllerId"],
        userDeviceId: json["userDeviceId"],
        groupId: json["groupId"],
        groupName: json["groupName"],
        deviceName: json["deviceName"],
        deviceId: json["deviceId"]
    );
  }
}