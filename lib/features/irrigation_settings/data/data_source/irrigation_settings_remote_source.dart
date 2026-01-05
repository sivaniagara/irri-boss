import 'dart:convert';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/utils/irrigation_settings_urls.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_urls.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/mqtt_service.dart' show MqttService;
import '../../../../core/di/injection.dart';

abstract class IrrigationSettingsRemoteSource{
  Future <Map<String, dynamic>> getTemplateSetting({required Map<String, String> urlData});
  Future <Map<String, dynamic>> getValveFlowSetting({required Map<String, String> urlData});
  Future <Map<String, dynamic>> getNodeList({required Map<String, String> urlData});
  Future<void> publishMqttCommand({required String controllerId, required String command});
  Future<void> logHistory({required String userId, required int subUserId, required String controllerId, required String sentSms});
  Future<void> saveValveFlowSettings({required String endpoint, required Map<String, dynamic> body, String method = 'POST'});
}

class IrrigationSettingsRemoteSourceImpl extends IrrigationSettingsRemoteSource{
  final ApiClient apiClient;
  IrrigationSettingsRemoteSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getTemplateSetting(
      {required Map<String, String> urlData}) async{
    try{
      String endPoint = buildUrl(IrrigationSettingsUrls.templateSetting, urlData);
      final response = await apiClient.get(endPoint);
      return response;
    } catch (e){
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getValveFlowSetting({required Map<String, String> urlData}) async {
    try {
      String endPoint = buildUrl(IrrigationSettingsUrls.valveFlowSetting, urlData);
      final response = await apiClient.get(endPoint);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getNodeList({required Map<String, String> urlData}) async {
    try {
      String endPoint = buildUrl(IrrigationSettingsUrls.nodeList, urlData);
      final response = await apiClient.get(endPoint);
      return response;
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
  Future<void> logHistory({required String userId, required int subUserId, required String controllerId, required String sentSms}) async {
    final historyEndpoint = 'user/$userId/subuser/$subUserId/controller/$controllerId/view/messages/';
    try {
      // Ensuring the body is a clean map with the single unified string
      await apiClient.post(historyEndpoint, body: {"sentSms": sentSms});
    } catch (e) {
      // Log failure but don't rethrow to avoid blocking the main flow
    }
  }

  @override
  Future<void> saveValveFlowSettings({required String endpoint, required Map<String, dynamic> body, String method = 'POST'}) async {
    try {
      if (method == 'PUT') {
        await apiClient.put(endpoint, body: body);
      } else {
        await apiClient.post(endpoint, body: body);
      }
    } catch (e) {
      rethrow;
    }
  }
}