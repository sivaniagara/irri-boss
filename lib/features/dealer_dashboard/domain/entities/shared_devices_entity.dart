class SharedDevicesEntity {
  final String userName;
  final int userId;
  final int shareUserId;
  final int controllerId;
  final int userDeviceId;
  final int groupId;
  final String groupName;
  final String deviceName;
  final String deviceId;

  SharedDevicesEntity({
    required this.userName,
    required this.userId,
    required this.shareUserId,
    required this.controllerId,
    required this.userDeviceId,
    required this.groupId,
    required this.groupName,
    required this.deviceName,
    required this.deviceId,
  });
}