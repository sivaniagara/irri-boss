import 'dart:convert';
import 'package:niagara_smart_drip_irrigation/core/services/api_client.dart';
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
  final ApiClient client;
  final MqttService mqttService;

  StandaloneRemoteDataSourceImpl(this.client, this.mqttService);

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
        client.get(settingsEndpoint),
        client.get(zoneListEndpoint),
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
      if (rawZoneList is List) {
        zoneListJson = rawZoneList;
      } else if (rawZoneList is Map) {
        final data = rawZoneList['data'];
        final zones = rawZoneList['zones'];
        if (data is List) {
          zoneListJson = data;
        } else if (zones is List) {
          zoneListJson = zones;
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
    final settingsEndpoint = 'user/$userId/subuser/$subuserId/controller/$controllerId/menu/$settingsId/settings';
    final historyEndpoint = 'user/$userId/subuser/$subuserId/controller/$controllerId/view/messages/';

    final Map<String, dynamic> sendDataMap = {
      "type": "21",
      "zoneList": config.zones.map((z) => {
        "zoneNumber": "ZONE ${z.zoneNumber.padLeft(3, '0')}",
        "status": z.status ? "1" : "0",
        "time": z.time
      }).toList(),
      "toggleStatus": config.settingValue,
      "driptoggleStatus": config.dripSettingValue
    };

    final body = {
      "menuSettingId": settingsId,
      "receivedData": "",
      "sentSms": sentSms,
      "sendData": jsonEncode(sendDataMap)
    };

    try {
      // 1. Save configuration
      await client.post(settingsEndpoint, body: body);
      // 2. Log to history
      await client.post(historyEndpoint, body: {"sentSms": sentSms});
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
      if (!mqttService.isConnected) {
        await mqttService.connect();
      }
      mqttService.publish(controllerId, command);
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
      await client.post(historyEndpoint, body: {"sentSms": sentSms});
    } catch (e) {
      // Log failure but don't rethrow to avoid blocking the main flow
    }
  }
}
