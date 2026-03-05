import 'dart:convert';
import '../../domain/entities/standalone_entity.dart';

class StandaloneModel extends StandaloneEntity {
  StandaloneModel({
    required super.zones,
    required super.settingValue,
    required super.dripSettingValue,
    required super.programName,
  });

  factory StandaloneModel.fromCombinedJson({
    required Map<String, dynamic> settingsJson,
    required List<dynamic> zoneJson,
  }) {
    String value = "0";
    String dripValue = "0";
    String programName = "Standalone";
    List<ZoneEntity> finalZones = [];

    // 1. Load hardware/configured zones (from zonelistv2 or program list)
    // These represent the "Created" zones.
    if (zoneJson.isNotEmpty) {
      finalZones = zoneJson.map((z) => ZoneModel.fromJson(Map<String, dynamic>.from(z as Map))).toList();
    }

    // 2. Process Manual Mode Settings (from menu settings)
    if (settingsJson['data'] != null && (settingsJson['data'] as List).isNotEmpty) {
      final dataItem = settingsJson['data'][0];
      programName = dataItem['menuItem']?.toString() ?? dataItem['templateName']?.toString() ?? programName;

      final dynamic rawSendData = dataItem['sendData'];
      if (rawSendData != null && rawSendData.toString().isNotEmpty) {
        try {
          final Map<String, dynamic> decoded = (rawSendData is String)
              ? json.decode(rawSendData)
              : Map<String, dynamic>.from(rawSendData);

          value = decoded['toggleStatus']?.toString() ?? "0";
          dripValue = decoded['driptoggleStatus']?.toString() ?? value;

          final List<dynamic>? savedZones = decoded['zoneList'];
          if (savedZones != null && savedZones.isNotEmpty) {
            final incomingSaved = savedZones.map((sz) => ZoneModel.fromJson(Map<String, dynamic>.from(sz as Map))).toList();
            
            if (finalZones.isEmpty) {
              finalZones = incomingSaved;
            } else {
              // Priority: We want to show the union of "Created" zones and "Saved" zones.
              // But we should HIDE a saved zone if it was deleted (i.e. not in finalZones) 
              // AND it is not active. 
              
              // For now, let's just make sure we don't lose Zone 5 if it's in saved but not hardware.
              // And let's update settings for those that match.
              for (var saved in incomingSaved) {
                final existingIndex = finalZones.indexWhere((z) => z.zoneNumber == saved.zoneNumber);
                if (existingIndex != -1) {
                  // Update existing hardware zone with saved time/status
                  finalZones[existingIndex] = ZoneEntity(
                    zoneNumber: finalZones[existingIndex].zoneNumber,
                    time: saved.time,
                    status: saved.status,
                  );
                } else {
                  // If it was saved in manual mode, it's likely still wanted by the user 
                  // even if it's currently missing from the hardware list.
                  // We only add it if it's active or has a custom time.
                  if (saved.status || saved.time != '00:00') {
                    finalZones.add(saved);
                  }
                }
              }
            }
          }
        } catch (_) {}
      }
    }

    // Sort zones numerically by ID
    finalZones.sort((a, b) {
      int? an = int.tryParse(a.zoneNumber);
      int? bn = int.tryParse(b.zoneNumber);
      if (an != null && bn != null) return an.compareTo(bn);
      return a.zoneNumber.compareTo(b.zoneNumber);
    });

    return StandaloneModel(
      settingValue: value,
      dripSettingValue: dripValue,
      zones: finalZones,
      programName: programName,
    );
  }

  static String normalizeZoneId(dynamic raw) {
    if (raw == null) return "0";
    String s = raw.toString();
    String digits = s.replaceAll(RegExp(r'[^0-9]'), '').trim();
    if (digits.isEmpty) return s;
    return int.tryParse(digits)?.toString() ?? digits;
  }
}

class ZoneModel extends ZoneEntity {
  ZoneModel({
    required super.zoneNumber,
    required super.time,
    required super.status,
  });

  factory ZoneModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['zoneNumber'] ?? json['zoneName'] ?? json['zone_number'] ?? json['zoneId'] ?? json['id'] ?? '0';
    
    // Support multiple status flags from different API responses
    bool isActive = json['status'].toString() == '1' ||
                    json['status'] == true ||
                    json['status'].toString().toLowerCase() == 'true' ||
                    json['active'] == true;

    return ZoneModel(
      zoneNumber: StandaloneModel.normalizeZoneId(rawId),
      time: json['time']?.toString() ?? '00:00',
      status: isActive,
    );
  }
}
