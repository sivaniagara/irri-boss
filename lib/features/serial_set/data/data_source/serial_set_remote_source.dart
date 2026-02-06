import 'package:niagara_smart_drip_irrigation/core/di/injection.dart';
import 'package:niagara_smart_drip_irrigation/core/services/api_client.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_manager.dart';
import 'package:niagara_smart_drip_irrigation/core/services/mqtt/mqtt_service.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/api_urls.dart';
import '../../presentation/utils/serial_set_urls.dart';
import '../model/serial_set_model.dart';

abstract class SerialSetRemoteSource {
  Future<SerialSetModel> getSerialSet({required Map<String, dynamic> urlData});
  Future<void> saveSerialSet({required String endpoint, required Map<String, dynamic> body});
  Future<void> publishMqtt({required String topic, required String command});
  Future<void> logHistory({required String userId, required String subuserId, required String controllerId, required String sentSms});
}

class SerialSetRemoteSourceImpl implements SerialSetRemoteSource {
  final ApiClient apiClient;
  SerialSetRemoteSourceImpl({required this.apiClient});

  @override
  Future<SerialSetModel> getSerialSet({required Map<String, dynamic> urlData}) async {
    String endpoint = buildUrl(SerialSetUrls.getSetSerial, urlData);
    final response = await apiClient.get(endpoint);
    if (response['code'] == 200 && response['data'] != null && (response['data'] as List).isNotEmpty) {
      return SerialSetModel.fromJson(response['data'][0]);
    }
    throw Exception('Failed to fetch serial set');
  }

  @override
  Future<void> saveSerialSet({required String endpoint, required Map<String, dynamic> body}) async {
    await apiClient.post(endpoint, body: body);
  }

  @override
  Future<void> publishMqtt({required String topic, required String command}) async {
    if (!sl<MqttService>().isConnected) {
      await sl<MqttService>().connect();
    }
    sl<MqttManager>().publish(topic, command);
  }

  @override
  Future<void> logHistory({required String userId, required String subuserId, required String controllerId, required String sentSms}) async {
    final historyEndpoint = buildUrl(SerialSetUrls.logHistory, {
      'userId': userId,
      'subuserId': subuserId,
      'controllerId': controllerId,
    });
    try {
      await apiClient.post(historyEndpoint, body: {"sentSms": sentSms});
    } catch (_) {}
  }
}
