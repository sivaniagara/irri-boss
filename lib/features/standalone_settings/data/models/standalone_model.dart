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
    List<ZoneEntity> finalZones = [];

    // 1. Baseline: Load zones from hardware zonelistv2 API
    if (zoneJson.isNotEmpty) {
      try {
        finalZones = zoneJson.map((z) {
          final map = Map<String, dynamic>.from(z as Map);
          return ZoneModel.fromJson(map);
        }).toList();
      } catch (_) {}
    }

    // 2. Settings Overlay: Apply saved configuration if available
    if (settingsJson['data'] != null && settingsJson['data'] is List && settingsJson['data'].isNotEmpty) {
      final dataItem = settingsJson['data'][0];
      
      if (dataItem['sendData'] != null && dataItem['sendData'].toString().isNotEmpty) {
        try {
          final decodedSendData = json.decode(dataItem['sendData'].toString());
          if (decodedSendData is Map<String, dynamic>) {
            value = decodedSendData['toggleStatus']?.toString() ?? "0";
            dripValue = decodedSendData['driptoggleStatus']?.toString() ?? value;
            
            // CRITICAL: Only overwrite finalZones if the saved config actually HAS zones.
            // In Configuration API (500), zoneList is often [], so we must NOT overwrite the baseline.
            if (decodedSendData['zoneList'] != null && 
                decodedSendData['zoneList'] is List && 
                (decodedSendData['zoneList'] as List).isNotEmpty) {
              finalZones = (decodedSendData['zoneList'] as List).map((z) {
                return ZoneModel.fromJson(Map<String, dynamic>.from(z as Map));
              }).toList();
            }
          }
        } catch (_) {}
      }

      // 3. Toggle Fallback Logic
      if (value == "0") {
        if (dataItem['templateJson'] != null) {
          try {
            final template = json.decode(dataItem['templateJson'].toString());
            if (template is Map<String, dynamic>) {
              value = template['toggleStatus']?.toString() ?? "0";
              dripValue = template['driptoggleStatus']?.toString() ?? value;
            }
          } catch (_) {}
        } else if (dataItem['value'] != null) {
          value = dataItem['value'].toString();
          dripValue = value;
        }
      }
    }

    return StandaloneModel(
      settingValue: value,
      dripSettingValue: dripValue, 
      zones: finalZones,
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
    // Extensive key checking to support different API response formats
    final dynamic rawNum = json['zoneNumber'] ?? 
                          json['zone_number'] ?? 
                          json['zoneNo'] ?? 
                          json['zone_id'] ?? 
                          json['id'] ?? 
                          '0';
    
    // Normalize zone number format
    String formattedNum = rawNum.toString().replaceAll(RegExp(r'[^0-9]'), '').trim();
    if (formattedNum.isEmpty) {
      formattedNum = rawNum.toString();
    }

    return ZoneModel(
      zoneNumber: formattedNum,
      time: json['time']?.toString() ?? '00:00',
      status: json['status'].toString() == '1' || 
              json['status'] == true || 
              json['status'].toString().toLowerCase() == 'true',
    );
  }
}
