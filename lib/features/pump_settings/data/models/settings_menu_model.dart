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
        templateName: json["templateName"] ?? "No name"
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "menuSettingId": menuSettingId,
      "referenceId": referenceId,
      "menuItem": menuItem,
      "templateName": templateName,
    };
  }

  factory SettingsMenuModel.fromEntity(SettingsMenuEntity entity) {
    return SettingsMenuModel(
      menuSettingId: entity.menuSettingId,
      referenceId: entity.referenceId,
      menuItem: entity.menuItem,
      templateName: entity.templateName,
    );
  }
}