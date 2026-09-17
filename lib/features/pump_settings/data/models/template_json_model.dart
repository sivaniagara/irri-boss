import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/template_json_entity.dart';

import '../../domain/entities/setting_widget_type.dart';

class TemplateJsonModel extends TemplateJsonEntity {
  const TemplateJsonModel({
    required super.sections,
    super.p2Sections = const [],
  });

  factory TemplateJsonModel.fromJson(Map<String, dynamic> json) {
    final sections = (json['setting'] ?? []) as List<dynamic>;
    final p2Sections = (json['p2Setting'] ?? []) as List<dynamic>;

    return TemplateJsonModel(
      sections: sections
          .map<SettingSectionEntity>((sectionJson) => SettingsSectionModel.fromJson(sectionJson))
          .toList(),
      p2Sections: p2Sections
          .map<SettingSectionEntity>((sectionJson) => SettingsSectionModel.fromJson(sectionJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      "setting": sections.map((section) => (section as SettingsSectionModel).toJson()).toList(),
    };
    if (p2Sections.isNotEmpty) {
      map["p2Setting"] = p2Sections.map((section) => (section as SettingsSectionModel).toJson()).toList();
    }
    return map;
  }

  factory TemplateJsonModel.fromEntity(TemplateJsonEntity entity) {
    return TemplateJsonModel(
      sections: entity.sections
          .map((section) => SettingsSectionModel.fromEntity(section))
          .toList(),
      p2Sections: entity.p2Sections
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
    required super.valueInHw,
    required super.smsFormat,
    required super.title,
    required super.hiddenFlag
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
        serialNumber: json["SN"],
        widgetType: SettingWidgetType.fromInt(json['WT'] ?? 0),
        value: json["VAL"] ?? '',
        valueInHw:  '',
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
      valueInHw: '',
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