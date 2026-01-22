class SettingsMenuEntity {
  final int menuSettingId;
  final int referenceId;
  final int hiddenFlag;
  final String menuItem;
  final String templateName;
  final String groupName;

  SettingsMenuEntity({
    required this.menuSettingId,
    required this.referenceId,
    required this.hiddenFlag,
    required this.menuItem,
    required this.templateName,
    required this.groupName
  });

  SettingsMenuEntity copyWith(int? hiddenFlag) {
    return SettingsMenuEntity(
        menuSettingId: menuSettingId,
        referenceId: referenceId,
        hiddenFlag: hiddenFlag ?? this.hiddenFlag,
        menuItem: menuItem,
        templateName: templateName,
        groupName: groupName
    );
  }
}