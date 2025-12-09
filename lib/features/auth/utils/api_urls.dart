class AuthUrls {
  static const String getAddress = '/maps/api/geocode/json?';
  static const String simVerification = 'verifysim';
  static const String getProfile = 'user/:userId';

  /// Post methods
  static const String signUp = 'user';
  static const String loginWithOtpUrl = 'signin1';
  static const String loginWithPasswordUrl = 'signin';
  static const String verifyUserUrl = 'verifyUser';
  static const String smsVerification = 'controller';

  /// Put methods
  static const String logOutUrl = 'signout';
  static const String forgotPassword = 'forgotpassword';
  static const String editProfile = 'user';
}