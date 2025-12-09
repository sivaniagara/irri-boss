class PumpSettingsUrls {
  /// Get methods
  static const String getSettingsMenu = 'user/:userId/subuser/:subuserId/controller/:controllerId/menu/:referenceId/settings';
  static const String getNotificationSettings = 'user/:userId/subuser/:subuserId/controller/:controllerId/message';
  static const String getFinalMenu = 'user/:userId/subuser/:subuserId/controller/:controllerId/menu/:referenceId/settings/:menuId';

  /// Post methods
  static const String addViewType4 = 'user/:userId/subuser/:subuserId/controller/:controllerId/menu/:referenceId/settings';
  static const String menuHide = 'user/:userId/subuser/:shareUserId/controller/:controllerId/menu/:menuId/hidemenu';

  /// Put methods
  static const String menuUnHide = 'user/:userId/subuser/:shareUserId/controller/:controllerId/menu/:menuId/hidemenu';
}