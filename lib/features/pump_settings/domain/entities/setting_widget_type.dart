enum SettingWidgetType {
  text,      // 1
  toggle,    // 2
  time,      // 3
  multiTime, // 4
  fullText,  // 5
  phone,     // 6
  multiText, // 7
  unknown;

  factory SettingWidgetType.fromInt(int value) {
    // Simple and fast lookup (recommended)
    switch (value) {
      case 1:
        return text;
      case 2:
        return toggle;
      case 3:
        return time;
      case 4:
        return multiTime;
      case 5:
        return fullText;
      case 6:
        return phone;
      case 7:
        return multiText;
      default:
        return unknown;
    }
  }

  int get serverValue => index + 1;
}