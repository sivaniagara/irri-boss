import 'package:flutter/material.dart';

class LoginPageState {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final String countryCode;
  final String? errorMessage;
  final bool isRateLimited;
  final bool useOtpLogin;

  LoginPageState({
    required this.formKey,
    required this.phoneController,
    required this.passwordController,
    required this.countryCode,
    this.errorMessage,
    required this.isRateLimited,
    required this.useOtpLogin,
  });

  factory LoginPageState.initial() {
    return LoginPageState(
      formKey: GlobalKey<FormState>(),
      phoneController: TextEditingController(),
      passwordController: TextEditingController(),
      countryCode: '+91',
      errorMessage: null,
      isRateLimited: false,
      useOtpLogin: false,
    );
  }

  LoginPageState copyWith({
    String? countryCode,
    String? errorMessage,
    bool? isRateLimited,
    bool? useOtpLogin,
  }) {
    return LoginPageState(
      formKey: formKey,
      phoneController: phoneController,
      passwordController: passwordController,
      countryCode: countryCode ?? this.countryCode,
      errorMessage: errorMessage,
      isRateLimited: isRateLimited ?? this.isRateLimited,
      useOtpLogin: useOtpLogin ?? this.useOtpLogin,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is LoginPageState &&
              runtimeType == other.runtimeType &&
              formKey == other.formKey &&
              phoneController == other.phoneController &&
              passwordController == other.passwordController &&
              countryCode == other.countryCode &&
              errorMessage == other.errorMessage &&
              isRateLimited == other.isRateLimited &&
              useOtpLogin == other.useOtpLogin;

  @override
  int get hashCode =>
      formKey.hashCode ^
      phoneController.hashCode ^
      passwordController.hashCode ^
      countryCode.hashCode ^
      errorMessage.hashCode ^
      isRateLimited.hashCode ^
      useOtpLogin.hashCode;
}