class DealerUrls {
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
}