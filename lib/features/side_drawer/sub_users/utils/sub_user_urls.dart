class SubUserUrls {
  /// Get methods
  static const String getSubUSer = 'user/:mobileno/details';
  static const String getSubUserDetails = 'user/:userId/shareuser/:mSubUserCode/details';
  static const String getSubUserList = 'user/:userId/shareuser/list';

  /// Post methods
  static const String addSubUser = 'user/share/controller';

  /// Put methods
  static const String updateSubUserDetails = 'user/share/controller';
  static const String deleteSubUserDetails = 'user/:userId/shareuser/:shareUserId';
}