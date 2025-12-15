class ApiUrls {
  //TODO: DEALER URLs
  /// Get methods
  static const String getSellingUnit = 'dealer/:userId/category/:categoryId';
  static const String deviceTraceDealer = 'dealer/:userId/tracecode/:deviceId';
  static const String getDealerDetails = 'dealer/:userId/product/:deviceId/details';
  static const String getDealerCustomerDetails = 'dealer/:userId/customer';
  static const String getDealerCustomerDeviceDetails = 'dealer/:dealerId/user/:userId/controller';

  /// Post methods
  static const String getSales = 'dealer/sales';
  static const String addController = 'dealer/controller';


  //TODO: SHARED URLs
  /// Get methods
  static const String getCustomerSharedDevice = 'user/:userId/invitee/list';
  static const String getCustomerSharedDeviceListItem = 'user/:userId/share/:shareId/controller';


  //TODO: REPORT URLs
  /// Get methods
  static const String getPowerData = 'user/:userId/subuser/:subuserId/controller/:controllerId/power/graph?';
  static const String getValveData = 'user/:userId/subuser/:subuserId/controller/:controllerId/zone/graph?';
  static const String getOnOffStatus = 'user/:userId/subuser/:subuserId/controller/:userDeviceId/manualstatus';

  /// Put methods
  static const String updateNotification = 'user/:userId/subuser/:subuserId/controller/:controllerId/message';


  //TODO: MY DEVICES URLs
  /// Get Methods
  static const String getMyDevicesWithoutGroupList = 'controller/user/:userId';
  static const String getMyDevicesWithGroupList = 'controller/user/:userId/cluster';
  static const String getMyDevicesWithGroupItemList = 'user/:userId/cluster/:groupId/controller';
  static const String getSellingDevices = ':categorylist';


  //TODO: CONTROLLER URLs
  /// Get methods
  static const String getControllerList = 'user/:userId/controller/list';
  static const String getViewControllerCustomerDetails = 'user/:userId/subuser/:subuserId/controller/:userDeviceId/view';

  /// Delete Methods
  static const String deleteViewControllerCustomerDetails = 'user/:userId/controller/:userDeviceId';

  /// Put methods
  static const String updateController = 'controller';


  //TODO: PROGRAM URLs
  /// Get Methods
  static const String getProgramList = 'user/:userId/controller/:controllerId/program';
  static const String getProgramsNodes = 'user/:userId/controller/:controllerId/program/:programId/node';


  //TODO: ZONE URLs
  /// Get methods
  static const String getZoneDetails = 'user/:userId/controller/:controllerId/program/:programId/zone/:zoneNumber';

  /// Post methods
  static const String addZoneNodes = 'user/:userId/controller/:controllerId/program/:programId/zone';

  /// Put methods
  static const String updateZoneNodes = 'user/:userId/controller/:controllerId/program/:programId/zone';

  /// Delete methods
  static const String resetZoneNodes = 'user/:userId/controller/:controllerId/program/:programId/zone/:zoneId?';


  //TODO: NODE URLs
  /// Get methods
  static const String deviceTrace = 'tracecode/:deviceId/?type=ctrl';
  static const String nodeTrace = 'tracecode/:deviceId?type=node';
  static const String getNodeDetails = 'user/:userId/node/:nodeId';
  static const String getNodeList = 'user/:userId/controller/:controllerId/nodeUnMapList';

  /// Post methods
  static const String addNode = 'node';
  static const String getNode = 'user/:userId/node';
  static const String getNodesList = 'user/:userId/subuser/:subuserId/controller/:controllerId/valve/status';
  static const String getValveListForProgram = 'user/:userId/subuser/:subuserId/controller/:controllerId/program/:programId/node';
  static const String getSingleNodeNodeList = 'user/:userId/controller/:controllerId/node/:nodeId';
  static const String addMappedNodeList = 'user/:userId/controller/:controllerId/node';

  /// Put methods
  static const String updateMappedNodeUpdate = 'user/:userId/controller/:controllerId/node/:nodeId';
  static const String updateNodeUpdate = 'user/:userId/node/:nodeId';
  static const String unMappedNodeDetails = 'user/:userId/controller/:controllerId/node/:nodeId?';

  /// Delete methods
  static const String deleteNodeDetails = 'user/:userId/node/:nodeId';


  //TODO: LIVE STATUS URLs
  /// Get methods
  static const String getLiveStatus = 'user/:userId/subuser/:subuserId/controller/:controllerId/call/:call/livestatus';
  static const String getLiveUpdate = 'user/:userId/subuser/:subuserId/controller/:controllerId';
  static const String stopLiveStatus = 'user/:userId/subuser/:subuserId/controller/:controllerId/livestatus/stop';


  //TODO: ZONE LIST URLs
  /// Get methods
  static const String getZoneList = 'user/:userId/subuser/:subuserId/controller/:controllerId/zonelistv2';
  static const String getValveListStandalone = 'user/:userId/subuser/:subuserId/controller/:controllerId/nodeliststandalone';


  //TODO: COMMON SETTINGS URLs
  /// Get methods
  static const String getCommonSetting = 'user/:userId/subuser/:subuserId/controller/:controllerId/commonsettings';

  /// Post methods
  static const String putCommonSetting = 'user/:userId/subuser/:subuserId/controller/:controllerId/commonsettings';

  /// Put methods
  static const String resetCommonSetting = 'user/:userId/subuser/:subuserId/controller/:controllerId/commonsettings';


  //TODO: DND AND MODE URLs
  /// Get methods
  static const String getDNDStatus = 'user/:userId/subuser/:subuserId/controller/:userDeviceId/dndstatus';
  static const String getOperationStatus = 'user/:userId/subuser/:subuserId/controller/:userDeviceId/mode';


  //TODO: PROGRAM NAME URLs
  /// Get methods
  static const String getProgramNameList = 'user/:userId/controller/:controllerId/programs';

  /// Put Methods
  static const String updateProgramName = 'user/:userId/subuser/:subuserId/program';


  //TODO: REPLACE URLs
  /// Put Methods
  static const String replaceController = 'user/:userId/subuser/:subuserId/replace';
  static const String replaceController1 = 'productrep';


  //TODO: ZONE SET URL
  /// Get Methods
  static const String getZoneSet = 'user/:userId/subuser/:shareUserId/controller/:controllerId/zoneset/:programId';


  //TODO: SERVICE REQUEST URLs
  /// Get Methods
  static const String getServiceRequestList = 'user/:userId/servicerequest';
  static const String deviceReplaceTraceDealer = 'user/:userId/subuser/:subuserId/controller/:deviceId/deviceId/:userDeviceId/replace';
  static const String deviceReplaceTraceDealer1 = 'productrep/traceProductnew/:traceId';

  /// Post methods
  static const String createService = 'user/:userId/subuser/:shareUserId/servicerequest/';

  /// Put methods
  static const String updateService = 'user/:userId/dealer/servicerequest/';


  //TODO: CHAT URLs
  /// Get Methods
  static const String getDealerChatListApi = 'user/:userId/dealer/list';
  static const String getChatListApi = 'user/:userId/fromUser/:fromUserId/chat/:chatFlag';
  static const String getChatMessageApi = 'user/:userId/receiver/:dealerId/chat';
  static const String getDealerListApi = 'admin/:userId/dealer/list';
  static const String getDealerCallListApi = 'user/:userId/dealer/call';

  /// Post methods
  static const String sendChatMessageApi = 'user/:userId/dealer/:dealerId/message';


  //TODO: FAULT MESSAGES URLs
  /// Get Methods
  static const String getFaultMessageList = 'user/:userId/subuser/:subUserId/controller/:controllerId/messages/';

  /// Post methods
  static const String addFaultSms = 'user/:userId/subuser/:subUserId/controller/messages/';


  //TODO: VIEW MESSAGES URLs
  /// Post methods
  static const String viewStatus = 'user/:userId/subuser/:subuserId/controller/:controllerId/view/messages/';
  static const String viewResendStatus = 'user/:userId/subuser/:subuserId/controller/:controllerId/view/resend/messages/';


  //TODO: MQTT URL
  /// Post methods
  static const String addMqttSms = 'controller/messages/';


  //TODO: TRACE URL
  /// Get methods
  static const String getTrace = '/';


  //TODO: MOBILE TRACE URL
  /// Get methods
  static const String getMobileNumberTrace = 'user/:userId/mobileNumber/:mobileNumber/type/:userType/username';


  //TODO: DASHBOARD URLS (Additional from partial)

  /// Get methods
  static const String dashboardForGroupUrl = 'controller/user/:userId/cluster';
  static const String dashboardUrl = 'user/:userId/cluster/:groupId/controller';

  //TODO: SetSerial URLS
  /// Get methods
  /// //%@/api/v1/user/%@/subuser/%d/controller/%d/menu/92/settings/481
  /// %@/api/v1/user/%@/subuser/0/controller/%d/view/messages/


  static const String getsetserialUrl = 'user/:userId/subuser/:subuserId/controller/:controllerId/menu/92/settings/481';
  static const String postsetserialUrl = 'user/:userId/cluster/:groupId/controller';
  static const String postsetserialviewUrl = 'user/:userId/cluster/:groupId/controller';
  static const String putserialsetUrl = 'user/:userId/cluster/:groupId/controller';
  //TODO: common calibration URLS
  /// Get methods
  static const String getcommncalUrl = 'user/:userId/subuser/:subuserId/controller/:controllerId/menu/92/settings/481';
  static const String putcommncalUrl = 'user/:userId/cluster/:groupId/controller';
  static const String getcommncalviewUrl = 'user/:userId/cluster/:groupId/controller';
  //TODO: Send & Receive Message URLS
  /// Get
  /// http://3.1.62.165:8080/api/v1/user/153/subuser/0/controller/938/report?fromDate='2025-12-04'&toDate='2025-12-04'&type=sendrevmsg
  static const String getSendRevMsgUrl = 'user/:userId/subuser/:subuserId/controller/:controllerId/report?fromDate=:fromdate&toDate=:toDate&type=sendrevmsg';

}

// Simple utility function for basic replacement.
String buildUrl(String urlTemplate, Map<String, String> params) {
  String url = urlTemplate;
  for (final entry in params.entries) {
    url = url.replaceAll(':${entry.key}', entry.value);
  }
  return url;
}
