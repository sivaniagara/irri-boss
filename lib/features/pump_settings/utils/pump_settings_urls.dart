class PumpSettingsUrls {
  static const String settingReferenceId = "600";
  static const String newSettings = "newSettings";
  /// Get methods
  static const String getSettingsMenu = 'user/:userId/subuser/:subuserId/controller/:controllerId/menu/$settingReferenceId/$newSettings';
  static const String getNotificationSettings = 'user/:userId/subuser/:subuserId/controller/:controllerId/message'; //GET & PUT
  static const String getFinalMenu = 'user/:userId/subuser/:subuserId/controller/:controllerId/menu/$settingReferenceId/$newSettings/:menuId';

  /// Post methods
  static const String addViewType4 = 'user/:userId/subuser/:subuserId/controller/:controllerId/menu/$settingReferenceId/$newSettings';
  static const String menuHide = 'user/:userId/subuser/:shareUserId/controller/:controllerId/menu/:menuId/hidemenu';
  static const String updateTemplate = 'user/:userId/subuser/:subuserId/controller/:controllerId/menu/$settingReferenceId/$newSettings';

  /// Put methods
  static const String menuUnHide = 'user/:userId/subuser/:shareUserId/controller/:controllerId/menu/:menuId/hidemenu';
}


//New Menu Settings
/*
router.get('/api/v1/user/:userId/subuser/:subUserId/controller/:controllerId/menu/$settingReferenceId/newSettings/:menuId', globalSetting.getNewMainMenuItems);
router.post('/api/v1/user/:userId/subuser/:subUserId/controller/:controllerId/menu/$settingReferenceId/newSettings', globalSetting.insertNewSettingData);


MenuID	ReferenceID	Name
502	600		Delay Settings
503	600		Current Settings
504	600		Voltage Settings
505	600		Timer Settings
506	600		SMS Settings
507	600		Communication Config
508	600		Status Check
509	600		Number Registration
510	600		View Setting
511	600		Other Setting
512	600		Pump Ctrl Sump
*/
