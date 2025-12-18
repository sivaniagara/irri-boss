class PumpSettingsImages {
  static const String img1 = "assets/images/pump_menu_icons/delay_settings.png";
  static const String img2 = "assets/images/pump_menu_icons/current_settings.png";
  static const String img3 = "assets/images/pump_menu_icons/voltage_settings.png";
  static const String img4 = "assets/images/pump_menu_icons/timer_settings.png";
  static const String img5 = "assets/images/pump_menu_icons/sms_settings.png";
  static const String img6 = "assets/images/pump_menu_icons/communication_config.png";
  static const String img7 = "assets/images/pump_menu_icons/status_check.png";
  static const String img8 = "assets/images/pump_menu_icons/number.png";
  static const String img9 = "assets/images/pump_menu_icons/view_settings.png";
  static const String img10 = "assets/images/pump_menu_icons/other_settings.png";
  static const String img11 = "assets/images/pump_menu_icons/sump_settings.png";
  static const String img12 = "assets/images/pump_menu_icons/notification_settings.png";
  static const String img13 = "assets/images/pump_menu_icons/pump_view_settings.png";

  static String getByIndex(int index) {
    switch (index) {
      case 1:
        return img1;
      case 2:
        return img2;
      case 3:
        return img3;
      case 4:
        return img4;
      case 5:
        return img5;
      case 6:
        return img6;
      case 7:
        return img7;
      case 8:
        return img8;
      case 9:
        return img9;
      case 10:
        return img10;
      case 11:
        return img11;
      case 12:
        return img12;
      case 13:
        return img13;
      default:
        return img1; // fallback
    }
  }
}