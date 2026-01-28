import 'dart:convert';
import '../../../../core/di/injection.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/mqtt_service.dart' show MqttService;
import '../../../../core/utils/api_urls.dart';
import '../models/valve_flow_model.dart';
import '../../utils/valve_flow_urls.dart';

abstract class ValveFlowRemoteSource {
  Future<ValveFlowModel> getValveFlowSetting({required Map<String, dynamic> urlData});
  Future<List<dynamic>> getNodeList({required Map<String, dynamic> urlData});
  Future<void> publishMqttCommand({required String controllerId, required String command});
<<<<<<< HEAD
=======
  Future<void> logHistory({required String userId, required int subUserId, required String controllerId, required String sentSms});
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
  Future<void> saveValveFlowSettings({required String endpoint, required Map<String, dynamic> body});
  Future<void> logHistory({
    required String userId,
    required String subuserId,
    required String controllerId,
    required String sentSms,
  });
}

class ValveFlowRemoteSourceImpl implements ValveFlowRemoteSource {
  final ApiClient apiClient;
  ValveFlowRemoteSourceImpl({required this.apiClient});

  @override
  Future<ValveFlowModel> getValveFlowSetting({required Map<String, dynamic> urlData}) async {
    try {
      String endPoint = buildUrl(ValveFlowUrls.valveFlowSetting, urlData);
      final response = await apiClient.get(endPoint);
      if (response['code'] == 200 && response['data'] != null && (response['data'] as List).isNotEmpty) {
        return ValveFlowModel.fromJson(response['data'][0]);
      }
      throw Exception('Failed to fetch valve flow setting');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<dynamic>> getNodeList({required Map<String, dynamic> urlData}) async {
    try {
      String endPoint = buildUrl(ValveFlowUrls.nodeList, urlData);
      final response = await apiClient.get(endPoint);
      if (response['code'] == 200) {
        return response['data'] as List<dynamic>;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> publishMqttCommand({required String controllerId, required String command}) async {
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
<<<<<<< HEAD
=======
  Future<void> logHistory({required String userId, required int subUserId, required String controllerId, required String sentSms}) async {
    final historyEndpoint = buildUrl(ValveFlowUrls.logHistory, {
      'userId': userId,
      'subUserId': subUserId,
      'controllerId': controllerId,
    });
    try {
      await apiClient.post(historyEndpoint, body: {"sentSms": sentSms});
    } catch (e) {
      // Log failure but don't rethrow
    }
  }

  @override
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
  Future<void> saveValveFlowSettings({required String endpoint, required Map<String, dynamic> body}) async {
    try {
      await apiClient.post(endpoint, body: body);
    } catch (e) {
<<<<<<< HEAD
      rethrow;
=======
      throw Exception('Failed to save valve flow settings: $e');
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
    }
  }

  @override
  Future<void> logHistory({
    required String userId,
    required String subuserId,
    required String controllerId,
    required String sentSms,
  }) async {
    final historyEndpoint = 'user/$userId/subuser/$subuserId/controller/$controllerId/view/messages/';
    try {
      await apiClient.post(historyEndpoint, body: {"sentSms": sentSms});
    } catch (e) {
      // Log failure but don't rethrow to avoid blocking the main flow
    }
  }
}
