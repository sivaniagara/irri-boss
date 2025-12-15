import 'package:equatable/equatable.dart';

import 'setting_widget_type.dart';

class TemplateJsonEntity extends Equatable{
  final List<SettingSectionEntity> sections;

  const TemplateJsonEntity({
    required this.sections,
  });

  TemplateJsonEntity copyWith({
    String? type,
    List<SettingSectionEntity>? sections,
  }) {
    return TemplateJsonEntity(
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

  @override
  List<Object?> get props => [sections];
}

class SettingsEntity extends Equatable {
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

  SettingsEntity copyWith({String? value, String? hiddenFlag}) {
    return SettingsEntity(
      serialNumber: serialNumber,
      widgetType: widgetType,
      value: value ?? this.value,
      smsFormat: smsFormat,
      title: title,
      hiddenFlag: hiddenFlag ?? this.hiddenFlag,
    );
  }

  @override
  List<Object?> get props => [serialNumber, widgetType, value, smsFormat, title, hiddenFlag];
}

class SettingSectionEntity extends Equatable{
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

  @override
  List<Object?> get props => [typeId, sectionName, settings];
}