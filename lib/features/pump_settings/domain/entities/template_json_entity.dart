import 'package:collection/collection.dart';

import 'setting_widget_type.dart';

class TemplateJsonEntity {
  final String type;
  final List<ParameterGroupEntity> groups;
  final List<SettingSectionEntity> sections;

  const TemplateJsonEntity({
    required this.type,
    required this.groups,
    required this.sections,
  });

  TemplateJsonEntity copyWith({
    String? type,
    List<ParameterGroupEntity>? groups,
    List<SettingSectionEntity>? sections,
  }) {
    return TemplateJsonEntity(
      type: type ?? this.type,
      groups: groups ?? this.groups,
      sections: sections ?? this.sections,
    );
  }

  TemplateJsonEntity copyWithSettingValue({
    required int serialNumber,
    required String newValue,
  }) {
    final updatedSections = sections.map((section) {
      return section.copyWithSetting(serialNumber, newValue);
    }).toList();

    return copyWith(sections: updatedSections);
  }
}

class ParameterGroupEntity {
  final String groupName;
  final List<ParameterItemEntity> items;

  const ParameterGroupEntity({
    required this.groupName,
    required this.items,
  });
}

class ParameterItemEntity {
  // Common fields
  final String? toggleType;
  final String? toggleStatus;
  final String? delayTime;
  final String? onTime;
  final String? offTime;
  final String? timeValue;
  final String? numberValue;
  final String? fromValue;
  final String? toValue;
  final String? progNumber;

  final String? phaseValue;
  final String? voltageValue;
  final String? voltageDifferenceValue;
  final String? voltagePlaceHolder;
  final String? differencePlaceHolder;

  final String? phase2Value;
  final String? phase3Value;

  const ParameterItemEntity({
    this.toggleType,
    this.toggleStatus,
    this.delayTime,
    this.onTime,
    this.offTime,
    this.timeValue,
    this.numberValue,
    this.fromValue,
    this.toValue,
    this.progNumber,
    this.phaseValue,
    this.voltageValue,
    this.voltageDifferenceValue,
    this.voltagePlaceHolder,
    this.differencePlaceHolder,
    this.phase2Value,
    this.phase3Value,
  });
}

class SettingsEntity {
  final int serialNumber;
  final SettingWidgetType widgetType;
  final String value;
  final String smsFormat;
  final String title;
  final String hiddenFlag;

  const SettingsEntity({
    required this.serialNumber,
    required this.widgetType,
    required this.value,
    required this.smsFormat,
    required this.title,
    required this.hiddenFlag,
  });

  SettingsEntity copyWith({String? value}) {
    return SettingsEntity(
      serialNumber: serialNumber,
      widgetType: widgetType,
      value: value ?? this.value,
      smsFormat: smsFormat,
      title: title,
      hiddenFlag: hiddenFlag,
    );
  }
}

class SettingSectionEntity {
  final int typeId;
  final String sectionName;
  final List<SettingsEntity> settings;

  const SettingSectionEntity({
    required this.typeId,
    required this.sectionName,
    required this.settings,
  });

  SettingSectionEntity copyWith({List<SettingsEntity>? settings,}) {
    return SettingSectionEntity(
      typeId: typeId,
      sectionName: sectionName,
      settings: settings ?? this.settings,
    );
  }

  SettingSectionEntity copyWithSetting(int serialNumber, String newValue) {
    return copyWith(
      settings: settings.map((s) {
        return s.serialNumber == serialNumber ? s.copyWith(value: newValue) : s;
      }).toList(),
    );
  }
}