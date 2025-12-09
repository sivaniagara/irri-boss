import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
// For platform-specific handling if needed
import 'package:get_it/get_it.dart';
import 'package:crypto/crypto.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/utils/api_urls.dart';
import 'dart:convert';

import '../../../../core/di/injection.dart' as di;
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_client.dart';
import '../../domain/auth_domain.dart';
import '../models/user_model.dart';
import 'auth_local_data_source.dart';

/// Abstract class defining the remote data source contract for authentication operations.
abstract class AuthRemoteDataSource {
  Future<RegisterDetailsModel> loginWithPassword(String phone, String password);
  Future<String> sendOtp(String phone);
  Future<void> logout();
  Future<RegisterDetailsModel> verifyOtp(String verificationId, String otp, String countryCode);
  Future<bool> checkPhoneNumber(String phone, String countryCode);
  Future<RegisterDetailsModel> signUp(SignUpParams params);
  Future<RegisterDetailsModel> updateProfile(UpdateProfileParams params);
}

/// Implementation of [AuthRemoteDataSource] using Firebase Auth and backend API.
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthRemoteDataSourceImpl({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Fetches device-specific information (token and IP address).
  /// In a production app, implement actual IP fetching via a service.
  Future<Map<String, String>> _getDeviceInfo() async {
    try {
      final deviceToken = await FirebaseMessaging.instance.getToken() ?? '';
      final ipAddress = ''; // TODO: Integrate with a network service to fetch real IP.
      if (kDebugMode) {
        print('Device token: $deviceToken, IP address: $ipAddress');
      }
      return {'deviceToken': deviceToken, 'macAddress': ipAddress};
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching device info: $e');
      }
      // Return empty values to avoid blocking; backend can handle gracefully.
      return {'deviceToken': '', 'macAddress': ''};
    }
  }

  /// Handles common API response parsing and error throwing.
  dynamic _handleApiResponse(dynamic response, {int successCode = 200, String operation = 'API call'}) {
    if (response['code'] == successCode) {
      return response['data'];
    } else {
      final message = response['message'] ?? 'Operation failed';
      throw AuthException(statusCode: response['code'].toString(), message: message);
    }
  }

  @override
  Future<RegisterDetailsModel> loginWithPassword(String phone, String password) async {
    try {
      final mobileNumber = _normalizePhoneNumber(phone);
      final deviceInfo = await _getDeviceInfo();

      final response = await _apiClient.post(
        AuthUrls.loginWithOtpUrl,
        // AuthUrls.loginWithPasswordUrl,
        body: {
          'mobileNumber': mobileNumber,
          'password': password,
          ...deviceInfo,
        },
      );

      if (kDebugMode) {
        print('Login API response: $response');
      }

      final data = _handleApiResponse(response, operation: 'Login');
      return RegisterDetailsModel.fromJson(data);
    } on AuthException {
      rethrow; // Preserve existing AuthExceptions
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      throw AuthException(statusCode: 'login-failed', message: 'Login failed: $e');
    }
  }

  @override
  Future<String> sendOtp(String phone) async {
    try {
      await _firebaseAuth.setLanguageCode('en');

      if (kIsWeb) {
        // Web-specific flow: Use signInWithPhoneNumber directly.
        final confirmationResult = await _firebaseAuth.signInWithPhoneNumber(phone);
        if (kDebugMode) {
          print('Web: OTP sent, verificationId=${confirmationResult.verificationId}');
        }
        return confirmationResult.verificationId;
      } else {
        // Mobile flow: Use verifyPhoneNumber with Completer for async handling.
        final completer = Completer<String>();
        await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phone,
          timeout: const Duration(seconds: 60),
          verificationCompleted: (PhoneAuthCredential credential) async {
            try {
              await _firebaseAuth.signInWithCredential(credential);
              // Auto-verification success; no need for manual OTP.
            } on FirebaseAuthException catch (e) {
              if (kDebugMode) {
                print('Auto-verification failed: ${e.code}');
              }
            }
          },
          verificationFailed: (FirebaseAuthException e) {
            if (kDebugMode) {
              print('Verification failed: ${e.code}, ${e.message}');
            }
            completer.completeError(
              AuthException(statusCode: e.code, message: e.message ?? 'Failed to send OTP'),
            );
          },
          codeSent: (String verificationId, int? resendToken) {
            if (kDebugMode) {
              print('OTP sent: verificationId=$verificationId');
            }
            if (!completer.isCompleted) {
              completer.complete(verificationId);
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            if (kDebugMode) {
              print('Code auto-retrieval timeout: verificationId=$verificationId');
            }
            if (!completer.isCompleted) {
              completer.complete(verificationId);
            }
          },
        );
        return await completer.future;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Send OTP error: $e');
      }
      throw AuthException(statusCode: 'otp-send-failed', message: 'Failed to send OTP: $e');
    }
  }

  @override
  Future<RegisterDetailsModel> verifyOtp(String verificationId, String otp, String countryCode) async {
    try {
      PhoneAuthCredential? credential;
      if (kIsWeb) {
        // Web-specific: Use PhoneAuthProvider.credential for confirmation.
        // Note: On web, this requires manual OTP input via confirm() on confirmationResult.
        // Assuming sendOtp returned confirmationResult; adjust if storing it.
        credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp);
      } else {
        credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp);
      }

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw AuthException(statusCode: 'null-user', message: 'User is null after OTP verification. Please try again.');
      }

      final idToken = await firebaseUser.getIdToken();
      final deviceInfo = await _getDeviceInfo();
      final mobileNumber = _normalizePhoneNumber(firebaseUser.phoneNumber ?? '', countryCode: countryCode);

      final response = await _apiClient.post(
        AuthUrls.loginWithOtpUrl,
        headers: {'Authorization': 'Bearer $idToken'},
        body: {
          'mobileNumber': mobileNumber,
          'password': '', // Empty for OTP flow
          ...deviceInfo,
        },
      );

      if (kDebugMode) {
        print('OTP Login API response: $response');
      }

      final data = _handleApiResponse(response, operation: 'OTP Verification');
      return RegisterDetailsModel.fromFirebaseUser(firebaseUser, data);
    } on FirebaseAuthException catch (e) {
      final message = _mapFirebaseAuthError(e.code, e.message);
      throw AuthException(statusCode: e.code, message: message);
    } on FirebaseException catch (e) {
      String message;
      if (e.code == 'app-check-token-error' || e.message?.contains('App attestation failed') == true) {
        message = 'App verification failed. Please ensure your app is properly configured.';
      } else {
        message = 'Firebase error: ${e.message ?? "An unknown error occurred."}';
      }
      throw AuthException(statusCode: e.code, message: message);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('Verify OTP error: $e');
        print('Verify OTP stacktrace: $stackTrace');
      }
      throw AuthException(statusCode: 'verification-failed', message: 'OTP verification failed: $e');
    }
  }

  /// Maps common Firebase Auth error codes to user-friendly messages.
  String _mapFirebaseAuthError(String code, String? defaultMessage) {
    switch (code) {
      case 'invalid-verification-code':
        return 'The OTP entered is invalid. Please try again.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please request a new OTP.';
      case 'session-expired':
        return 'The OTP session has expired. Please request a new OTP.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'billing-not-enabled':
        return 'Billing is not enabled for this project. Please contact support.';
      default:
        return defaultMessage ?? 'Authentication failed: An error occurred.';
    }
  }

  @override
  Future<bool> checkPhoneNumber(String phone, String countryCode) async {
    try {
      final body = {
        'mobileNumber': phone,
        'countryCode': countryCode.substring(1),
      };

      if (kDebugMode) {
        print('Check phone body: $body');
      }

      final response = await _apiClient.post(AuthUrls.verifyUserUrl, body: body);

      if (kDebugMode) {
        print('Check phone response: $response');
      }

      return response['code'] == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Check phone number error: $e');
      }
      throw AuthException(statusCode: 'phone-check-failed', message: 'Failed to check phone number: $e');
    }
  }

  @override
  Future<RegisterDetailsModel> signUp(SignUpParams params) async {
    try {
      final deviceInfo = await _getDeviceInfo();

      final body = {
        'mobileCountryCode': '91',
        'mobileNumber': params.mobile,
        'userName': params.name,
        'userType': params.userType ?? '',
        "language":1,
        'addressOne': params.addressOne ?? '',
        'addressTwo': params.addressTwo ?? '',
        'town': params.town ?? '',
        'village': params.village ?? '',
        'country': 'IND',
        'state': 'TN',
        'city': params.city ?? '',
        'postalCode': params.postalCode ?? '',
        'altPhoneNum': [
          {'mobileNumber': params.altPhone}
        ],
        'email': params.email ?? '',
        'password': md5.convert(utf8.encode(params.password ?? '')).toString(),
        ...deviceInfo,
      };

      final response = await _apiClient.post(AuthUrls.signUp, body: body);

      if (kDebugMode) {
        print('Sign up req body: $body');
        print('Sign up response: $response');
      }

      final data = _handleApiResponse(response, operation: 'Sign up');
      return RegisterDetailsModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print('Sign up error: $e');
      }
      throw AuthException(statusCode: 'signup-failed', message: 'Sign up failed: $e');
    }
  }

  @override
  Future<RegisterDetailsModel> updateProfile(UpdateProfileParams params) async {
    try {
      final body = {
        'userId': params.id,
        'name': params.name,
        'addressOne': params.addressOne,
        'mobile': params.mobile,
        'userType': params.userType,
        'addressTwo': params.addressTwo,
        'town': params.town,
        'village': params.village,
        'country': params.country,
        'state': params.state,
        'city': params.city,
        'postalCode': params.postalCode,
        'altPhone': params.altPhone,
        'email': params.email,
        'password': params.password ?? '', // Optional password update
      };

      // Note: Consider using PUT instead of POST for updates if backend supports it.
      final response = await _apiClient.put(AuthUrls.editProfile, body: body); // Or apiClient.put if available

      if (kDebugMode) {
        print('Update profile response: $response');
      }

      final data = _handleApiResponse(response, operation: 'Profile update');
      return RegisterDetailsModel.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print('Update profile error: $e');
      }
      throw AuthException(statusCode: 'profile-update-failed', message: 'Profile update failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Sign out from Firebase
      await _firebaseAuth.signOut();

      // Clear local cached auth data
      final authLocalDataSource = GetIt.instance<AuthLocalDataSource>();
      await authLocalDataSource.clearAuthData();
      await di.sl.reset();
      await di.init();
      await _apiClient.put(AuthUrls.logOutUrl, body: {});
      if (kDebugMode) {
        print('User logged out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Logout error: $e');
      }
      // Don't throw on logout failure; it's non-critical
      rethrow;
    }
  }

  /// Normalizes phone number by extracting the last 10 digits if it starts with '+'.
  String _normalizePhoneNumber(String phone, {String? countryCode}) {
    if (phone.startsWith('+')) {
      return phone.substring(phone.length - 10);
    }
    if (countryCode != null && phone.startsWith(countryCode)) {
      return phone.substring(countryCode.length);
    }
    return phone;
  }
}