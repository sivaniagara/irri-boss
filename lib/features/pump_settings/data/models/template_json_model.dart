import 'package:niagara_smart_drip_irrigation/features/pump_settings/data/models/settings_menu_model.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/template_json_entity.dart';

import '../../domain/entities/setting_widget_type.dart';

class TemplateJsonModel extends TemplateJsonEntity {
  const TemplateJsonModel({
    required super.sections,
  });

  factory TemplateJsonModel.fromJson(Map<String, dynamic> json) {
    final sections = json['setting'] as List<dynamic>;

    return TemplateJsonModel(
      sections: sections
          .map<SettingSectionEntity>((sectionJson) => SettingsSectionModel.fromJson(sectionJson))
          .toList(),
    );
  }

  // ADD THIS
  Map<String, dynamic> toJson() {
    return {
      "setting": sections.map((section) => (section as SettingsSectionModel).toJson()).toList(),
    };
  }

  factory TemplateJsonModel.fromEntity(TemplateJsonEntity entity) {
    return TemplateJsonModel(
      sections: entity.sections
          .map((section) => SettingsSectionModel.fromEntity(section))
          .toList(),
    );
  }
}

class SettingsModel extends SettingsEntity {
  const SettingsModel({
    required super.serialNumber,
    required super.widgetType,
    required super.value,
    required super.smsFormat,
    required super.title,
    required super.hiddenFlag
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
        serialNumber: json["SN"],
        widgetType: SettingWidgetType.fromInt(json['WT'] ?? 0),
        value: json["VAL"] ?? '',
        smsFormat: json["SF"],
        title: json["TT"],
        hiddenFlag: json["HF"]
    );
  }

  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      serialNumber: entity.serialNumber,
      widgetType: entity.widgetType,
      value: entity.value,
      smsFormat: entity.smsFormat,
      title: entity.title,
      hiddenFlag: entity.hiddenFlag,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "SN" : serialNumber,
      "WT": widgetType.toInt(),
      "VAL" : value,
      "SF" : smsFormat,
      "TT" : title,
      "HF" : hiddenFlag
    };
  }
}

class SettingsSectionModel extends SettingSectionEntity {
  const SettingsSectionModel({
    required super.typeId,
    required super.sectionName,
    required super.settings,
  });

  factory SettingsSectionModel.fromJson(Map<String, dynamic> json) {
    return SettingsSectionModel(
      typeId: json["TID"] as int,
      sectionName: json["NAME"] as String,
      settings: (json["SETS"] as List<dynamic>)
          .map((e) => SettingsModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "TID": typeId,
      "NAME": sectionName,
      "SETS": settings.map((setting) => (setting as SettingsModel).toJson()).toList(),
    };
  }

  factory SettingsSectionModel.fromEntity(SettingSectionEntity entity) {
    return SettingsSectionModel(
      typeId: entity.typeId,
      sectionName: entity.sectionName,
      settings: entity.settings
          .map((setting) => SettingsModel.fromEntity(setting))
          .toList(),
    );
  }
}