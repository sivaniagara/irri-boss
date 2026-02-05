class StandaloneEntity {
  final List<ZoneEntity> zones;
  final String settingValue;
  final String dripSettingValue;
  final String programName;

  StandaloneEntity({
    required this.zones,
    required this.settingValue,
    required this.dripSettingValue,
    this.programName = "(P1) Drip",
  });
}

class ZoneEntity {
  final String zoneNumber;
  final String time;
  final bool status;

  ZoneEntity({
    required this.zoneNumber,
    required this.time,
    required this.status,
  });
}
