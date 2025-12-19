class ControllerSettingsUrls{
  static String getProgram = 'user/:userId/controller/:controllerId/program';
  static String addZone = 'user/:userId/controller/:controllerId/program/:programId/node';
  static String submitZone = 'user/:userId/controller/:controllerId/program/:programId/zone';
  static String deleteZone = 'user/:userId/controller/:controllerId/program/:programId/zone/:zoneSerialNo?&s1=IDZONESELPP1001,000,000,000,&s2=IDZLMSETPP1001,000,000,000,';
  static String editZone = 'user/:userId/controller/:controllerId/program/:programId/zone/:zoneSerialNo';
}