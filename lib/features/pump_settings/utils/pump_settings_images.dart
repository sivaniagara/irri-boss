class PumpSettingsImages {
  static String getMenuIcons(int typeId) {
    final id = typeId == 0 ? 515 : typeId;
    return "assets/images/pump_menu_icons/$id.png";
  }

  static String getCommunicationConfigIcons(String path) => "assets/images/communication_config_icons/$path.png";

  static String getStatusCheckIcons(String path) => "assets/images/controller_status_check/$path.png";
}