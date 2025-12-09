import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../dashboard/data/models/group_model.dart';
import '../../domain/entities/user_entity.dart';

class RegisterDetailsModel extends RegisterDetailsEntity {
  RegisterDetailsModel({
    required super.userDetails,
    required super.mqttIPAddress,
    required super.mqttUserName,
    required super.mqttPassword,
    required super.groupDetails,
  });

  factory RegisterDetailsModel.fromJson(Map<String, dynamic> json) {
    return RegisterDetailsModel(
      userDetails: UserModel.fromJson(json['regDetails'] as Map<String, dynamic>),
      mqttIPAddress: json['mqttIPAddress'] as String? ?? '',
      mqttUserName: json['mqttUserName'] as String? ?? '',
      mqttPassword: json['mqttPassword'] as String? ?? '',
      groupDetails: (json['groupDetails'] as List<dynamic>?)
          ?.map((item) => GroupDetails.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  factory RegisterDetailsModel.fromJsonString(String jsonString) {
    final Map<String, dynamic> map = jsonDecode(jsonString);
    return RegisterDetailsModel.fromJson(map);
  }

  factory RegisterDetailsModel.fromFirebaseUser(User firebaseUser, Map<String, dynamic> json) {
    return RegisterDetailsModel(
      userDetails: UserModel.fromFirebaseUser(firebaseUser, json['regDetails'] as Map<String, dynamic>),
      mqttIPAddress: json['mqttIPAddress'] as String? ?? '',
      mqttUserName: json['mqttUserName'] as String? ?? '',
      mqttPassword: json['mqttPassword'] as String? ?? '',
      groupDetails: (json['groupDetails'] as List<dynamic>?)?.map((item) => GroupDetails.fromJson(item as Map<String, dynamic>)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'regDetails': (userDetails as UserModel).toJson(),
      'mqttIPAddress': mqttIPAddress,
      'mqttUserName': mqttUserName,
      'mqttPassword': mqttPassword,
      'groupDetails': groupDetails.map((item) => (item as GroupDetails).toJson()).toList(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  RegisterDetailsEntity toEntity() => this;
}

class UserModel extends UserEntity{
  UserModel({
    required super.id,
    required super.name,
    required super.mobile,
    required super.userType,
    required super.deviceToken,
    required super.mobCctv,
    required super.webCctv,
    super.addressOne,
    super.addressTwo,
    super.village,
    super.town,
    super.city,
    super.postalCode,
    super.country,
    super.state,
    super.email,
    required super.altPhoneNum,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print("json in UserModel :: $json");
    return UserModel(
      id: json['userId'] as int? ?? 0,
      name: json['userName'] as String? ?? '',
      mobile: '${json['mobileCountryCode'] ?? ''}${json['mobileNumber'] ?? ''}',
      userType: json['userType'] is String ? int.parse(json['userType'] ?? '0') : (json['userType'] as int? ?? 0),
      deviceToken: json['deviceToken'] as String? ?? '',
      mobCctv: json['mobCctv'] as String? ?? '',
      webCctv: json['webCctv'] as String? ?? '',
      addressOne: json['addressOne'] as String?,
      addressTwo: json['addressTwo'] as String?,
      village: json['village'] as String?,
      town: json['town'] as String?,
      city: json['city'] as String?,
      postalCode: json['postalCode'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      email: json['email'] as String?,
      altPhoneNum: (json['altPhoneNum'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  factory UserModel.fromFirebaseUser(User firebaseUser, Map<String, dynamic> regDetails) {
    return UserModel(
      id: regDetails['userId'] as int? ?? 0,
      name: regDetails['userName'] as String? ?? '',
      mobile: firebaseUser.phoneNumber ?? '',
      userType: regDetails['userType'] is String ? int.parse(regDetails['userType'] ?? '0') : (regDetails['userType'] as int? ?? 0),
      deviceToken: regDetails['deviceToken'] as String? ?? '',
      mobCctv: regDetails['mobCctv'] as String? ?? '',
      webCctv: regDetails['webCctv'] as String? ?? '',
      addressOne: regDetails['addressOne'] as String?,
      addressTwo: regDetails['addressTwo'] as String?,
      village: regDetails['village'] as String?,
      town: regDetails['town'] as String?,
      city: regDetails['city'] as String?,
      postalCode: regDetails['postalCode'] as String?,
      country: regDetails['country'] as String?,
      state: regDetails['state'] as String?,
      email: regDetails['email'] as String? ?? firebaseUser.email,
      altPhoneNum: (regDetails['altPhoneNum'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': id,
      'userName': name,
      'mobileCountryCode': mobile.startsWith('+') ? int.parse(mobile.substring(1, mobile.length - 10)) : 0,
      'mobileNumber': mobile.startsWith('+') ? int.parse(mobile.substring(mobile.length - 10)) : 0,
      'userType': userType,
      'deviceToken': deviceToken,
      'mobCctv': mobCctv,
      'webCctv': webCctv,
      'addressOne': addressOne,
      'addressTwo': addressTwo,
      'village': village,
      'town': town,
      'city': city,
      'postalCode': postalCode,
      'country': country,
      'state': state,
      'email': email,
      'altPhoneNum': altPhoneNum,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      mobile: mobile,
      userType: userType,
      deviceToken: deviceToken,
      mobCctv: mobCctv,
      webCctv: webCctv,
      addressOne: addressOne,
      addressTwo: addressTwo,
      village: village,
      town: town,
      city: city,
      postalCode: postalCode,
      country: country,
      state: state,
      email: email,
      altPhoneNum: altPhoneNum,
    );
  }
}