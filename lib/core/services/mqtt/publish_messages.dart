class PublishMessageHelper {
  static const String key = "sentSms";
  static const Map<String, dynamic> requestLive = {key: "#live"};
  static Map<String, dynamic> settingsPayload(String value) => {key: value};
  static const Map<String, dynamic> pumpViewSettingsRequest = {key: "#vpumpset"};
}