import 'dart:convert';
import '../../domain/entities/standalone_entity.dart';

class StandaloneModel extends StandaloneEntity {
  StandaloneModel({
    required super.zones,
    required super.settingValue,
    required super.dripSettingValue,
  });

  factory StandaloneModel.fromCombinedJson({
    required Map<String, dynamic> settingsJson,
    required List<dynamic> zoneJson,
  }) {
    String value = "0";
    String dripValue = "0";

    if (settingsJson['data'] != null && settingsJson['data'] is List && settingsJson['data'].isNotEmpty) {
      final dataItem = settingsJson['data'][0];
      
      // Try to get value from 'value' field (Standalone API style)
      if (dataItem['value'] != null) {
        value = dataItem['value'].toString();
        dripValue = value; // Default both to same if only one value exists
      } 
      // Try to get value from 'templateJson' (Configuration API style)
      else if (dataItem['templateJson'] != null) {
        try {
          final template = json.decode(dataItem['templateJson']);
          value = template['toggleStatus']?.toString() ?? "0";
          // Check for drip specific status if it exists in template
          dripValue = template['driptoggleStatus']?.toString() ?? value;
        } catch (_) {}
      }
    }

    return StandaloneModel(
      settingValue: value,
      dripSettingValue: dripValue, 
      zones: zoneJson.map((zone) => ZoneModel.fromJson(zone)).toList(),
    );
  }
}

class ZoneModel extends ZoneEntity {
  ZoneModel({
    required super.zoneNumber,
    required super.time,
    required super.status,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    return ZoneModel(
      zoneNumber: json['zone_number']?.toString() ?? '',
      time: json['time']?.toString() ?? '00:00:',
      status: json['status'] == 1 || json['status'] == true,
    );
  }
}
