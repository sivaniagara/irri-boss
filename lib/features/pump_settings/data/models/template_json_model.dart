import 'package:niagara_smart_drip_irrigation/features/pump_settings/data/models/settings_menu_model.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/template_json_entity.dart';

import '../../domain/entities/setting_widget_type.dart';

class TemplateJsonModel extends TemplateJsonEntity {
  const TemplateJsonModel({
    required super.sections
  });

  factory TemplateJsonModel.fromJson(Map<String, dynamic> json) {
    final sections = json['setting'];

    return TemplateJsonModel(
      sections: sections.map<SettingSectionEntity>((sectionJson) => SettingsSectionModel.fromJson(sectionJson)).toList()
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

  Map<String, dynamic> toJson() {
    return {
      "SN" : serialNumber,
      "WT" : widgetType,
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
    required super.settings
  });

  factory SettingsSectionModel.fromJson(Map<String, dynamic> json) {
    return SettingsSectionModel(
        typeId: json["TID"],
        sectionName: json["NAME"],
        settings: (json["SETS"] as List<dynamic>)
            .map((e) => SettingsModel.fromJson(e as Map<String, dynamic>))
            .toList()
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "TID": typeId,
      "NAME": sectionName,
      "SETS": settings
    };
  }
}