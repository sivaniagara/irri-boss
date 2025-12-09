import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/domain/entities/sub_user_entity.dart';

class SubUserModel extends SubUserEntity {
  SubUserModel({
    required super.userName,
    required super.mobileCountryCode,
    required super.mobileNumber,
    required super.sharedUserId,
    required super.subUserCode,
    required super.subuserId,
  });

  factory SubUserModel.fromJson(Map<String, dynamic> json) {
    return SubUserModel(
      userName: json["userName"],
      mobileCountryCode: json["mobileCountryCode"] ?? json["mobCountryCode"],
      mobileNumber: json["mobileNumber"],
      sharedUserId: json["sharedUserId"] ?? json['shareUserId'],
      subUserCode: json["subUserCode"],
      subuserId: json["subuserId"],
    );
  }
}