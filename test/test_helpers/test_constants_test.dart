import 'package:flutter_test/flutter_test.dart';
import '../test_helpers/test_constants.dart';

void main() {
  group('TestConstants', () {
    test('should have correct test user credentials', () {
      expect(TestConstants.testEmail, 'test@example.com');
      expect(TestConstants.testPassword, 'Test@1234');
      expect(TestConstants.testPhone, '+1234567890');
      expect(TestConstants.testName, 'Test User');
    });

    test('should have correct test OTP', () {
      expect(TestConstants.testOtp, '123456');
    });

    test('should have correct test address information', () {
      expect(TestConstants.testAddress, '123 Test St');
      expect(TestConstants.testCity, 'Test City');
      expect(TestConstants.testState, 'Test State');
      expect(TestConstants.testCountry, 'Test Country');
      expect(TestConstants.testPostalCode, '12345');
    });

    test('should have correct test device information', () {
      expect(TestConstants.testDeviceId, 'test-device-id');
      expect(TestConstants.testFcmToken, 'test-fcm-token');
    });

    test('should have correct timeout durations', () {
      expect(TestConstants.pumpTimeout, const Duration(seconds: 10));
      expect(TestConstants.defaultTimeout, const Duration(seconds: 30));
    });
  });
}
