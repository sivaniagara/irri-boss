// Domain entities for user details
import '../../../dashboard/domain/entities/group_entity.dart';

class UserEntity {
  final int id;
  final String name;
  final String mobile;
  final int userType;
  String? deviceToken;
  final String mobCctv;
  final String webCctv;
  final String? addressOne;
  final String? addressTwo;
  final String? village;
  final String? town;
  final String? city;
  final String? postalCode;
  final String? country;
  final String? state;
  final String? email;
  final List<String> altPhoneNum;

  UserEntity({
    required this.id,
    required this.name,
    required this.mobile,
    required this.userType,
    required this.deviceToken,
    required this.mobCctv,
    required this.webCctv,
    this.addressOne,
    this.addressTwo,
    this.village,
    this.town,
    this.city,
    this.postalCode,
    this.country,
    this.state,
    this.email,
    required this.altPhoneNum,
  });
}

// Domain entities for the entire registration details response
class RegisterDetailsEntity {
  final UserEntity userDetails;
  final String mqttIPAddress;
  final String mqttUserName;
  final String mqttPassword;
  final List<GroupDetailsEntity> groupDetails;

  const RegisterDetailsEntity({
    required this.userDetails,
    required this.mqttIPAddress,
    required this.mqttUserName,
    required this.mqttPassword,
    required this.groupDetails,
  });
}