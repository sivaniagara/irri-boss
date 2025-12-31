
class DashboardUrls {
  /// Get methods
  static const String dashboardForGroupUrl = 'controller/user/:userId/cluster';
  static const String dashboardUrl = 'user/:userId/cluster/:groupId/controller';
  static const String motorOnOffUrl = 'user/:userId/subuser/:subuserId/controller/:controllerId/manualstatus';

  static String get todayFormatted => Conversions.dateFormatter.format(DateTime.now());

  static String nodeStatusUrl({
    required String userId,
    required String subuserId,
    required String controllerId,
  }) {
    final String fromDate = todayFormatted;
    final String toDate = todayFormatted;

    return 'user/$userId/subuser/$subuserId/controller/$controllerId/report'
        '?fromDate=$fromDate&toDate=$toDate&type=mappednodes';
  }
}