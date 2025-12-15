import 'package:intl_phone_field/phone_number.dart';

import '../entities/setting_widget_type.dart';
import '../entities/template_json_entity.dart';

class SmsPayloadBuilder {
  static String build(SettingsEntity setting) {
    String value = setting.value.trim();

    return switch (setting.widgetType) {
      SettingWidgetType.phone => _buildPhonePayload(setting, value),
      SettingWidgetType.multiTime || SettingWidgetType.multiText => _buildMultiTimePayload(setting, value),
      SettingWidgetType.toggle when setting.title == 'DND' => _buildDndPayload(setting),
      _ => _buildDefaultPayload(setting, value),
    };
  }

  static String _buildDefaultPayload(SettingsEntity s, String value) {
    return "${s.smsFormat}$value"
        .replaceAll(':', '')
        .replaceAll(';', ',')
        .replaceAll(RegExp(r'\s+'), '');
  }

  static String _buildMultiTimePayload(SettingsEntity s, String value) {
    return "${s.smsFormat},$value"
        .replaceAll(':', '')
        .replaceAll(';', ',')
        .replaceAll(RegExp(r'\s+'), '');
  }

  static String _buildPhonePayload(SettingsEntity s, String completeNumber) {
    final phone = PhoneNumber.fromCompleteNumber(completeNumber: completeNumber);
    final spiltPayload = s.smsFormat.split(",");
    spiltPayload[1] = phone.countryCode;
    spiltPayload[2] = phone.number;
    return spiltPayload.join(',');
  }

  static String _buildDndPayload(SettingsEntity s) {
    final parts = s.smsFormat.split(',');
    parts[2] = s.value == "ON" ? "1" : "0";
    return parts.join(',');
  }
}