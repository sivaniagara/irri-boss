enum SettingWidgetType {
  text(1),
  toggle(2),
  time(3),
  multiTime(4),
  fullText(5),
  phone(6),
  multiText(7)
  ;

  final int value;

  const SettingWidgetType(this.value);

  // Convert enum → int
  int toInt() => value;

  // Convert int → enum (used in fromJson)
  static SettingWidgetType fromInt(int val) {
    return SettingWidgetType.values.firstWhere(
          (e) => e.value == val,
      orElse: () => SettingWidgetType.text, // default fallback
    );
  }
}