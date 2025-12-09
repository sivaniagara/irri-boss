import 'package:equatable/equatable.dart';

class LoginParams extends Equatable {
  final String phone;
  final String password;
  const LoginParams({required this.phone, required this.password});

  @override
  List<Object?> get props => [phone, password];
}

class PhoneParams extends Equatable {
  final String phone;
  final String countryCode;
  const PhoneParams(this.phone, this.countryCode);

  @override
  List<Object?> get props => [phone, countryCode];
}

class VerifyOtpParams extends Equatable {
  final String verificationId;
  final String otp;
  final String countryCode;

  const VerifyOtpParams({required this.verificationId, required this.otp, required this.countryCode});
  @override
  List<Object?> get props => [verificationId, otp, countryCode];
}

class SignUpParams extends Equatable {
  final String mobile;
  final String name;
  final int? userType; // e.g., from dropdown 'option'
  final String? addressOne;
  final String? addressTwo;
  final String? town;
  final String? village;
  final String? country;
  final String? state;
  final String? city;
  final String? postalCode;
  final String? altPhone;
  final String? email;
  final String? password;

  const SignUpParams({
    required this.mobile,
    required this.name,
    required this.userType,
    required this.addressOne,
    required this.addressTwo,
    required this.town,
    required this.village,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
    required this.altPhone,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [mobile, name, userType, addressOne, addressTwo, town, village, country, state, city, postalCode, altPhone, email, password];
}

class UpdateProfileParams extends Equatable {
  final int id;
  final String name;
  final String? addressOne;
  final String mobile;
  final int? userType;
  final String? addressTwo;
  final String? town;
  final String? village;
  final String? country;
  final String? state;
  final String? city;
  final String? postalCode;
  final String? altPhone;
  final String? email;
  final String? password;
  const UpdateProfileParams({
    required this.addressOne,
    required this.mobile,
    required this.userType,
    required this.addressTwo,
    required this.town,
    required this.village,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
    required this.altPhone,
    required this.email,
    required this.password,
    required this.id,
    required this.name});

  @override
  List<Object?> get props => [
    addressOne,
    mobile,
    userType,
    addressTwo,
    town,
    village,
    country,
    state,
    city,
    postalCode,
    altPhone,
    email,
    password,
    id,
    name
  ];
}