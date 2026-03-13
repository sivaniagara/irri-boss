import 'dart:convert';
import 'package:niagara_smart_drip_irrigation/core/services/api_client.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_manager.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/mqtt/mqtt_service.dart' show MqttService;
import '../../domain/entities/standalone_entity.dart';
import '../models/standalone_model.dart';

abstract class StandaloneRemoteDataSource {
  Future<StandaloneModel> fetchStandaloneData({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String menuId,
    required String settingsId,
  });

  Future<void> sendStandaloneConfig({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String menuId,
    required String settingsId,
    required StandaloneEntity config,
    required String sentSms,
  });

  Future<void> publishMqttCommand({
    required String controllerId,
    required String command,
  });

  Future<void> logHistory({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String sentSms,
  });
}

class StandaloneRemoteDataSourceImpl implements StandaloneRemoteDataSource {

  StandaloneRemoteDataSourceImpl();

  @override
  Future<StandaloneModel> fetchStandaloneData({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String menuId,
    required String settingsId,
  }) async {
    final settingsEndpoint = 'user/$userId/subuser/$subuserId/controller/$controllerId/menu/$menuId/settings/$settingsId';
    
    // Program 1 is the standard source for Standalone template configuration
    final programSettingsEndpoint = 'user/$userId/controller/$controllerId/program/1/timeflowsetting';

    try {
      final results = await Future.wait([
        sl<ApiClient>().get(settingsEndpoint),
        sl<ApiClient>().get(programSettingsEndpoint),
      ]);

      final dynamic rawSettings = results[0];
      final dynamic rawProgramData = results[1];

      Map<String, dynamic> settingsJson = {};
      if (rawSettings is Map<String, dynamic>) {
        settingsJson = rawSettings;
      } else if (rawSettings is List) {
        settingsJson = {'data': rawSettings};
      }

      List<dynamic> zoneListJson = [];
      
      // Navigate the program data: data -> setting -> zones
      if (rawProgramData is Map && rawProgramData['data'] != null) {
        final data = rawProgramData['data'];
        
        // Structure A: data -> setting -> zones (Standard for Program API)
        if (data is Map && data['setting'] != null && data['setting']['zones'] is List) {
          final List<dynamic> allZones = data['setting']['zones'];
          zoneListJson = _filterActiveZones(allZones);
        } 
        // Structure B: data -> zones (Fallback)
        else if (data is Map && data['zones'] is List) {
          zoneListJson = _filterActiveZones(data['zones']);
        }
        // Structure C: data is a direct List (Alternative fallback)
        else if (data is List) {
          zoneListJson = _filterActiveZones(data);
        }
      }

      return StandaloneModel.fromCombinedJson(
        settingsJson: settingsJson,
        zoneJson: zoneListJson,
      );
    } catch (e) {
      throw Exception('Failed to fetch standalone data: $e');
    }
  }

  /// Filters zones that are considered "Configured" or "Active" by the user.
  /// This ensures every customer sees exactly the blocks they've set up in Edit Program.
  List<dynamic> _filterActiveZones(List<dynamic> zones) {
    return zones.where((z) {
      if (z is! Map) return false;
      
      // Check for 'active' flag (boolean or string)
      final active = z['active'];
      final bool isActive = active == true || active == 1 || active.toString().toLowerCase() == 'true';
      
      // Check for 'status' flag as backup
      final status = z['status'];
      final bool hasStatus = status == true || status == 1 || status.toString() == '1' || status.toString().toLowerCase() == 'true';
      
      // If the block is active or has status, it's a configured block
      return isActive || hasStatus;
    }).toList();
  }

  @override
  Future<void> sendStandaloneConfig({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String menuId,
    required String settingsId,
    required StandaloneEntity config,
    required String sentSms,
  }) async {
    final settingsEndpoint = 'user/$userId/subuser/$subuserId/controller/$controllerId/menu/$menuId/settings';

    final Map<String, dynamic> sendDataMap = {
      "toggleStatus": config.settingValue,
      "driptoggleStatus": config.dripSettingValue,
      "type": "21",
      "zoneList": config.zones.map((z) => {
        "time": z.time,
        "zoneNumber": "ZONE ${z.zoneNumber.padLeft(3, '0')}",
        "status": z.status ? "1" : "0"
      }).toList(),
    };

    final body = {
      "menuSettingId": int.tryParse(settingsId) ?? 59,
      "receivedData": "",
      "sentSms": sentSms,
      "sendData": jsonEncode(sendDataMap)
    };

    try {
      await sl<ApiClient>().post(settingsEndpoint, body: body);
    } catch (e) {
      throw Exception('Failed to send configuration: $e');
    }
  }

  @override
  Future<void> publishMqttCommand({
    required String controllerId,
    required String command,
  }) async {
    try {
      if (!sl<MqttService>().isConnected) {
        await sl<MqttService>().connect();
      }
      sl<MqttManager>().publish(controllerId, command);
    } catch (e) {
      throw Exception('Failed to publish MQTT command: $e');
    }
  }

  @override
  Future<void> logHistory({
    required String userId,
    required int subuserId,
    required String controllerId,
    required String sentSms,
  }) async {
    final historyEndpoint = 'user/$userId/subuser/$subuserId/controller/$controllerId/view/messages/';
    try {
      await sl<ApiClient>().post(historyEndpoint, body: {"sentSms": sentSms});
    } catch (e) {
    }
  }
}
