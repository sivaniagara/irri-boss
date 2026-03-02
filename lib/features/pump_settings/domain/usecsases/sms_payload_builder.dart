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
    String processedValue = value;
    
    // Handle specific padding for DROCCURNBR
    if (s.smsFormat == "DROCCURNBR") {
      final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
      if (number != null) {
        processedValue = number.toString().padLeft(2, '0');
      }
    }

    return "${s.smsFormat}$processedValue"
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
    if (completeNumber.isEmpty) return "";
    try {
      final phone = PhoneNumber.fromCompleteNumber(completeNumber: completeNumber);
      final List<String> parts = s.smsFormat.split(",");

      if (s.smsFormat.startsWith("REG")) {
        // Format: REGxx,+CC,Number
        return "${parts[0]},+${phone.countryCode},${phone.number}";
      }

      // Existing logic for other phone types, ensuring indices are valid
      List<String> resultParts = List.from(parts);
      while (resultParts.length < 3) {
        resultParts.add("");
      }

      resultParts[1] = '+${phone.countryCode}';
      resultParts[2] = phone.number;

      if (resultParts.length > 3) {
        resultParts[3] = "$deviceId,1234";
      }
      return resultParts.join(',');
    } catch (e) {
      // Fallback if phone parsing fails
      return "${s.smsFormat}$completeNumber";
    }
  }

  static String _buildDndPayload(SettingsEntity s) {
    final parts = s.smsFormat.split(',');
    if (parts.length < 3) {
      return "${s.smsFormat},${s.value == "ON" ? "1" : "0"}";
    }
    parts[2] = s.value == "ON" ? "1" : "0";
    return parts.join(',');
  }

  static String _buildDateTimePayload(SettingsEntity s) {
    final now = DateTime.now();
    final formatter = DateFormat("','yy','MM','dd','HH','mm','ss");
    return "DT${formatter.format(now)}";
  }
}
