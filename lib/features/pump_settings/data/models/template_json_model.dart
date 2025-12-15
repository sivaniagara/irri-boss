import 'package:niagara_smart_drip_irrigation/features/pump_settings/data/models/settings_menu_model.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/template_json_entity.dart';

import '../../domain/entities/setting_widget_type.dart';

class TemplateJsonModel extends TemplateJsonEntity {
  TemplateJsonModel({
    required super.type,
    required super.groups,
    required super.sections
  });

  factory TemplateJsonModel.fromJson(Map<String, dynamic> json, List<Map<String, dynamic>> staticTemplate) {
    // print("json in the TemplateJsonModel :: $json");
    final String type = json['type'] as String;

    final groups = <ParameterGroupEntity>[];

    json.forEach((key, value) {
      // Skip the 'type' field and non-list values
      if (key == 'type' || value is! List) return;

      final items = value.map<ParameterItemEntity>((itemJson) {
        return ParameterItemModel.fromJson(itemJson as Map<String, dynamic>);
      }).toList();

      groups.add(ParameterGroupEntity(
        groupName: key,
        items: items,
      ));
    });

    return TemplateJsonModel(
      type: type,
      groups: groups,
      sections: staticTemplate.map<SettingSectionEntity>((sectionJson) => SettingsSectionModel.fromJson(sectionJson)).toList()
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {'type': type};

    for (final group in groups) {
      final itemsJson = group.items.map((item) {
        // Use the model's toJson if it's a model, fallback to entity
        return item is ParameterItemModel
            ? item.toJson()
            : _entityToJson(item);
      }).toList();

      map[group.groupName] = itemsJson;
    }

    return map;
  }

  // Helper: fallback if somehow a pure entity is in the list
  static Map<String, dynamic> _entityToJson(ParameterItemEntity entity) {
    return ParameterItemModel(
      toggleType: entity.toggleType,
      toggleStatus: entity.toggleStatus,
      delayTime: entity.delayTime,
      onTime: entity.onTime,
      offTime: entity.offTime,
      timeValue: entity.timeValue,
      numberValue: entity.numberValue,
      fromValue: entity.fromValue,
      toValue: entity.toValue,
      progNumber: entity.progNumber,
      phaseValue: entity.phaseValue,
      voltageValue: entity.voltageValue,
      voltageDifferenceValue: entity.voltageDifferenceValue,
      voltagePlaceHolder: entity.voltagePlaceHolder,
      differencePlaceHolder: entity.differencePlaceHolder,
      phase2Value: entity.phase2Value,
      phase3Value: entity.phase3Value,
    ).toJson();
  }
}

class ParameterItemModel extends ParameterItemEntity {
  const ParameterItemModel({
    super.toggleType,
    super.toggleStatus,
    super.delayTime,
    super.onTime,
    super.offTime,
    super.timeValue,
    super.numberValue,
    super.fromValue,
    super.toValue,
    super.progNumber,
    super.phaseValue,
    super.voltageValue,
    super.voltageDifferenceValue,
    super.voltagePlaceHolder,
    super.differencePlaceHolder,
    super.phase2Value,
    super.phase3Value,
  });

  factory ParameterItemModel.fromJson(Map<String, dynamic> json) {
    return ParameterItemModel(
      toggleType: json['toggleType'] as String?,
      toggleStatus: json['toggleStatus'] as String?,
      delayTime: json['delayTime'] as String?,
      onTime: json['onTime'] as String?,
      offTime: json['offTime'] as String?,
      timeValue: json['timeValue'] as String?,
      numberValue: json['numberValue'] as String?,
      fromValue: json['fromValue'] as String?,
      toValue: json['toValue'] as String?,
      progNumber: json['progNumber']?.toString(),
      phaseValue: json['phaseValue']?.toString(),
      voltageValue: json['voltageValue'] as String?,
      voltageDifferenceValue: json['voltageDifferenceValue'] as String?,
      voltagePlaceHolder: json['voltagePlaceHolder'] as String?,
      differencePlaceHolder: json['differencePlaceHolder'] as String?,
      phase2Value: json['phase2Value'] as String?,
      phase3Value: json['phase3Value'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (toggleType != null) 'toggleType': toggleType,
      if (toggleStatus != null) 'toggleStatus': toggleStatus,
      if (delayTime != null) 'delayTime': delayTime,
      if (onTime != null) 'onTime': onTime,
      if (offTime != null) 'offTime': offTime,
      if (timeValue != null) 'timeValue': timeValue,
      if (numberValue != null) 'numberValue': numberValue,
      if (fromValue != null) 'fromValue': fromValue,
      if (toValue != null) 'toValue': toValue,
      if (progNumber != null) 'progNumber': progNumber,
      if (phaseValue != null) 'phaseValue': phaseValue,
      if (voltageValue != null) 'voltageValue': voltageValue,
      if (voltageDifferenceValue != null) 'voltageDifferenceValue': voltageDifferenceValue,
      if (voltagePlaceHolder != null) 'voltagePlaceHolder': voltagePlaceHolder,
      if (differencePlaceHolder != null) 'differencePlaceHolder': differencePlaceHolder,
      if (phase2Value != null) 'phase2Value': phase2Value,
      if (phase3Value != null) 'phase3Value': phase3Value,
    };
  }
}

class SettingsModel extends SettingsEntity {
  SettingsModel({
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
  SettingsSectionModel({
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