import 'package:intl/intl.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../entities/setting_widget_type.dart';
import '../entities/template_json_entity.dart';

class SmsPayloadBuilder {
  static String build(SettingsEntity setting, String deviceId) {
    String value = setting.value.trim();

    return switch (setting.widgetType) {
      SettingWidgetType.phone => _buildPhonePayload(setting, value, deviceId),
      SettingWidgetType.multiTime || SettingWidgetType.multiText => _buildMultiTimePayload(setting, value),
      SettingWidgetType.toggle when setting.title == 'DND' => _buildDndPayload(setting),
      SettingWidgetType.nothing when setting.title == 'Date & Time' => _buildDateTimePayload(setting),
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

  static String _buildPhonePayload(SettingsEntity s, String completeNumber, String deviceId) {
    final phone = PhoneNumber.fromCompleteNumber(completeNumber: completeNumber);
    final spiltPayload = s.smsFormat.split(",");
    spiltPayload[1] = '+${phone.countryCode}';
    spiltPayload[2] = phone.number;
    if(spiltPayload.length > 3) {
      spiltPayload[3] = "$deviceId,1234";
    }
    return spiltPayload.join(',');
  }

  static String _buildDndPayload(SettingsEntity s) {
    final parts = s.smsFormat.split(',');
    parts[2] = s.value == "ON" ? "1" : "0";
    return parts.join(',');
  }

  static String _buildDateTimePayload(SettingsEntity s) {
    final now = DateTime.now();

    final formatter = DateFormat("','yy','MM','dd','HH','mm','ss");

    return "DT${formatter.format(now)}";
  }
}