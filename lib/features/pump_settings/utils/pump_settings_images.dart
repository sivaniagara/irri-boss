class PumpSettingsImages {
  static String getMenuIcons(int typeId) {
    Map<int, int> getImage = {
      538 : 503,
      541 : 506,
      547 : 513,
      539 : 504,
      540 : 505,
      546 : 512,
      542 : 507,
      543 : 508,
      545 : 510,
      548 : 514,
      544 : 509,
      549 : 511,
      550 : 515
    };
    int id = typeId == 0 ? 515 : typeId;
    if(getImage.containsKey(typeId)){
      id = getImage[typeId]!;
    }
    return "assets/images/pump_menu_icons/$id.png";
  }

  static String getCommunicationConfigIcons(String path) => "assets/images/communication_config_icons/$path.png";

  static String getStatusCheckIcons(String path) => "assets/images/controller_status_check/$path.png";
}
