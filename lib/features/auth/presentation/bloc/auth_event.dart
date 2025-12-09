import 'package:equatable/equatable.dart';
import '../../domain/auth_domain.dart';
import '../../../../core/usecases/usecase.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginWithPasswordEvent extends AuthEvent {
  final String phone;
  final String password;
  LoginWithPasswordEvent({required this.phone, required this.password});

  @override
  List<Object?> get props => [phone, password];
}

class SendOtpEvent extends AuthEvent {
  final String phone;
  final String countryCode;
  SendOtpEvent({required this.phone, required this.countryCode});

  @override
  List<Object?> get props => [phone, countryCode];
}

class VerifyOtpEvent extends AuthEvent {
  final String verificationId;
  final String otp;
  final String countryCode;
  VerifyOtpEvent({required this.otp, required this.countryCode, required this.verificationId});

  @override
  List<Object?> get props => [otp, countryCode, verificationId];
}

class LogoutEvent extends AuthEvent {
  final NoParams params = const NoParams();
}

class CheckCachedUserEvent extends AuthEvent {}

class CheckPhoneNumberEvent extends AuthEvent {
  final String phone;
  final String countryCode;
  CheckPhoneNumberEvent({required this.phone, required this.countryCode});

  @override
  List<Object?> get props => [phone, countryCode];
}

class SignUpEvent extends AuthEvent {
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

  SignUpEvent({
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
  List<Object?> get props => [];
}

class UpdateProfileEvent extends AuthEvent {
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

  UpdateProfileEvent({
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
    required this.name
  });

  @override
  List<Object?> get props => [];
}