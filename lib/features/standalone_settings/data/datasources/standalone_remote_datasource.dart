import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/services/mqtt_service.dart';
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
    required String deviceId,
    required String command,
  });
}

class StandaloneRemoteDataSourceImpl implements StandaloneRemoteDataSource {
  final http.Client client;
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
    final settingsUrl = 'http://3.1.62.165:8080/api/v1/user/$userId/subuser/$subuserId/controller/$controllerId/menu/$menuId/settings/$settingsId';
    final zoneListUrl = 'http://3.1.62.165:8080/api/v1/user/$userId/subuser/$subuserId/controller/$controllerId/zonelistv2';

    try {
      final responses = await Future.wait([
        client.get(Uri.parse(settingsUrl)),
        client.get(Uri.parse(zoneListUrl)),
      ]);

      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final settingsJson = json.decode(responses[0].body);
        final zoneListBody = json.decode(responses[1].body);
        
        List<dynamic> zoneListJson;
        if (zoneListBody is Map && zoneListBody['data'] is List) {
          zoneListJson = zoneListBody['data'];
        } else if (zoneListBody is List) {
          zoneListJson = zoneListBody;
        } else {
          zoneListJson = [];
        }

        return StandaloneModel.fromCombinedJson(
          settingsJson: settingsJson,
          zoneJson: zoneListJson,
        );
      } else {
        throw Exception('Server Error');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
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
    // Exact URL from sample: user/%@/subuser/0/controller/%d/menu/59/settings
    final url = 'http://3.1.62.165:8080/api/v1/user/$userId/subuser/$subuserId/controller/$controllerId/menu/$settingsId/settings';
    
    final body = {
      "menuSettingId": settingsId,
      "receivedData": "",
      "sentSms": sentSms,
      "sendData": {
        "type": "21",
        "zoneList": config.zones.map((z) => {
          "zoneNumber": "ZONE ${z.zoneNumber.padLeft(3, '0')}",
          "status": z.status ? "1" : "0",
          "time": z.time
        }).toList(),
        "toggleStatus": config.settingValue,
        "driptoggleStatus": config.dripSettingValue
      }
    };

    try {
      final response = await client.post(
        Uri.parse(url),
        body: json.encode(body),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send configuration (Code: ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  @override
  Future<void> publishMqttCommand({
    required String deviceId,
    required String command,
  }) async {
    if (!mqttService.isConnected) {
      await mqttService.connect();
    }
    mqttService.publish(deviceId, command);
  }
}
