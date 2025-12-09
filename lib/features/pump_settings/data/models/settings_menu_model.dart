import '../../domain/entities/settings_menu_entity.dart';

class SettingsMenuModel extends SettingsMenuEntity {
  SettingsMenuModel({
    required super.menuSettingId,
    required super.referenceId,
    required super.menuItem,
    required super.templateName
  });

  factory SettingsMenuModel.fromJson(Map<String, dynamic> json) {
    return SettingsMenuModel(
        menuSettingId: json["menuSettingId"],
        referenceId: json["referenceId"],
        menuItem: json["menuItem"],
        templateName: json["templateName"]
    );
  }
}