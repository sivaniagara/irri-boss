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
    final zoneListEndpoint = 'user/$userId/subuser/$subuserId/controller/$controllerId/zonelistv2';

    try {
      final results = await Future.wait([
        sl<ApiClient>().get(settingsEndpoint),
        sl<ApiClient>().get(zoneListEndpoint),
      ]);

      final dynamic rawSettings = results[0];
      final dynamic rawZoneList = results[1];

      Map<String, dynamic> settingsJson = {};
      if (rawSettings is Map<String, dynamic>) {
        settingsJson = rawSettings;
      } else if (rawSettings is List) {
        settingsJson = {'data': rawSettings};
      }

      List<dynamic> zoneListJson = [];
      if (rawZoneList is Map) {
        final data = rawZoneList['data'];
        if (data is List) {
          final Set<String> uniqueZoneIds = {};
          for (var item in data) {
             // Handle list of programs or direct list of zones
             final List<dynamic> list = (item is Map && item.containsKey('zoneList')) 
                 ? item['zoneList'] 
                 : (item is Map && item.containsKey('zones')) 
                     ? item['zones'] 
                     : [item];
             
             for (var zone in list) {
               if (zone is! Map) continue;
               final rawId = zone['zoneNumber'] ?? zone['zoneName'] ?? zone['zoneId'] ?? zone['id'];
               if (rawId != null) {
                 final normalized = StandaloneModel.normalizeZoneId(rawId);
                 
                 // FILTER: A zone is "Created" if it has hardware mapping
                 final bool hasNode = zone['nodeId'] != null && zone['nodeId'] != 0 && zone['nodeId'] != '0';
                 final bool hasValves = zone['valves'] is List && (zone['valves'] as List).isNotEmpty;
                 final bool isActive = zone['active'] == true || zone['status'] == 1 || zone['status'] == "1";

                 if ((hasNode || hasValves || isActive) && !uniqueZoneIds.contains(normalized)) {
                   uniqueZoneIds.add(normalized);
                   zoneListJson.add(zone);
                 }
               }
             }
          }
        } else if (data is Map) {
          // Response 1 or 3 style
          final List<dynamic> sourceList = data['zoneList'] ?? 
                                         (data['setting'] != null ? data['setting']['zones'] : null) ?? 
                                         data['zones'] ?? [];
          
          for (var zone in sourceList) {
            final bool hasNode = zone['nodeId'] != null && zone['nodeId'] != 0 && zone['nodeId'] != '0';
            final bool hasValves = zone['valves'] is List && (zone['valves'] as List).isNotEmpty;
            final bool isActive = zone['active'] == true || zone['status'] == 1 || zone['status'] == "1";

            if (hasNode || hasValves || isActive) {
              zoneListJson.add(zone);
            }
          }
        }
      } else if (rawZoneList is List) {
        zoneListJson = rawZoneList;
      }

      return StandaloneModel.fromCombinedJson(
        settingsJson: settingsJson,
        zoneJson: zoneListJson,
      );
    } catch (e) {
      throw Exception('Failed to fetch standalone data: $e');
    }
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
