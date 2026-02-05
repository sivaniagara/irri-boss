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

    // 1. Load Hardware Zones
    if (zoneJson.isNotEmpty) {
      finalZones = zoneJson.map((z) => ZoneModel.fromJson(Map<String, dynamic>.from(z as Map))).toList();
    }

    // 2. Process Settings Data
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
            // If we have no hardware zones, use the saved ones as a base
            if (finalZones.isEmpty) {
              finalZones = savedZones.map((sz) => ZoneModel.fromJson(Map<String, dynamic>.from(sz as Map))).toList();
            } else {
              // Priority: Overlay saved times/status onto hardware structure using robust ID matching
              for (var i = 0; i < finalZones.length; i++) {
                final hwZone = finalZones[i];
                final savedMatch = savedZones.firstWhere(
                      (sz) => normalizeZoneId(sz['zoneNumber']) == hwZone.zoneNumber,
                  orElse: () => null,
                );
                if (savedMatch != null) {
                  finalZones[i] = ZoneEntity(
                    zoneNumber: hwZone.zoneNumber,
                    time: savedMatch['time']?.toString() ?? hwZone.time,
                    status: savedMatch['status'].toString() == '1' || savedMatch['status'] == true,
                  );
                }
              }
            }
          }
        } catch (_) {}
      }
    }

    return StandaloneModel(
      settingValue: value,
      dripSettingValue: dripValue,
      zones: finalZones,
      programName: programName,
    );
  }

  /// Robustly extracts the numeric ID from strings like "ZONE 001", "Zone 1", or "1"
  static String normalizeZoneId(dynamic raw) {
    if (raw == null) return "0";
    String s = raw.toString();
    String digits = s.replaceAll(RegExp(r'[^0-9]'), '').trim();
    if (digits.isEmpty) return s;
    // Parse to int and back to string to remove leading zeros: "001" -> "1"
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
    final dynamic rawId = json['zoneNumber'] ?? json['zone_number'] ?? json['id'] ?? '0';
    return ZoneModel(
      zoneNumber: StandaloneModel.normalizeZoneId(rawId),
      time: json['time']?.toString() ?? '00:00',
      status: json['status'].toString() == '1' ||
          json['status'] == true ||
          json['status'].toString().toLowerCase() == 'true',
    );
  }
}
