import 'sub_user_entity.dart';

class SubUserDetailsEntity {
  final SubUserEntity subUserDetail;
  final List<SubUserControllerEntity> controllerList;

  SubUserDetailsEntity({
    required this.subUserDetail,
    required this.controllerList
  });
}

class SubUserControllerEntity {
  final int userDeviceId;
  final int productId;
  final String deviceName;
  final String deviceId;
  final String simNumber;
  final String dndStatus;
  final dynamic shareFlag;

  SubUserControllerEntity({
    required this.userDeviceId,
    required this.productId,
    required this.deviceName,
    required this.simNumber,
    required this.dndStatus,
    required this.shareFlag,
    required this.deviceId,
  });
}