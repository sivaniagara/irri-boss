import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/data/model/sub_user_model.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/domain/entities/sub_user_details_entity.dart';

class SubUserControllerModel extends SubUserControllerEntity {
  SubUserControllerModel({
    required super.userDeviceId,
    required super.productId,
    required super.deviceName,
    required super.simNumber,
    required super.dndStatus,
    required super.shareFlag,
    required super.deviceId
  });

  factory SubUserControllerModel.fromJson(Map<String, dynamic> json) {
    return SubUserControllerModel(
        userDeviceId: json['userDeviceId'],
        productId: json['productId'],
        deviceName: json['deviceName'],
        simNumber: json['simNumber'],
        dndStatus: json['dndStatus'] ?? '',
        shareFlag: json['shareFlag'],
        deviceId: json['deviceId']
    );
  }
}

class SubUserDetailsModel extends SubUserDetailsEntity {
  SubUserDetailsModel({
    required super.subUserDetail,
    required super.controllerList
  });

  factory SubUserDetailsModel.fromJson(Map<String, dynamic> json) {
    return SubUserDetailsModel(
      subUserDetail: SubUserModel.fromJson(json['shareUserDetails']),
      controllerList: (json['controllerList'] as List<dynamic>)
          .map((ctrlJson) => SubUserControllerModel.fromJson(ctrlJson as Map<String, dynamic>))
          .toList(),
    );
  }
}