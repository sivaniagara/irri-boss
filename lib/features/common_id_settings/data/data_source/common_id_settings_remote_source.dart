
import '../../../../core/services/api_client.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/utils/api_urls.dart';
import '../../../program_settings/utils/program_settings_urls.dart';
import '../../utils/common_id_settings_urls.dart';

abstract class CommonIdSettingsRemoteSource{
  Future<Map<String, dynamic>> getCommonIdSettings(Map<String, String> data);
  Future<Map<String, dynamic>> updateCategoryNodeSerialNo({required Map<String, String> urlData, required Map<String, dynamic> body});
  Future<bool> sendMessageViaMqtt({
    required String userId,
    required String controllerId,
    required String programId,
    required String deviceId,
    required String payload
  });
}

class CommonIdSettingsDataSourceImpl extends CommonIdSettingsRemoteSource{
  final ApiClient apiClient;
  final MqttManager mqttManager;
  CommonIdSettingsDataSourceImpl({
    required this.apiClient,
    required this.mqttManager,
  });

  @override
  Future<Map<String, dynamic>> getCommonIdSettings(Map<String, String> data)async {
    try{
      String endpoint = buildUrl(CommonIdSettingsUrls.getCommonIdSettings, data);
      final response = await apiClient.get(endpoint);
      return response;
    }catch (e){
      print('getCommonIdSettings error in data source impl : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateCategoryNodeSerialNo({required Map<String, String> urlData, required Map<String, dynamic> body}) async{
    try{
      String endpoint = buildUrl(CommonIdSettingsUrls.getCommonIdSettings, urlData);
      final response = await apiClient.post(endpoint, body: body);
      return response;
    }catch (e){
      print('updateCategoryNodeSerialNo error in data source impl : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<bool> sendMessageViaMqtt({
    required String userId,
    required String controllerId,
    required String programId,
    required String deviceId,
    required String payload
  }) async{
    try{
      String endPoint = buildUrl(
          CommonIdSettingsUrls.sentAndReceive,
          {
            'userId': userId,
            'controllerId': controllerId,
            'programId': programId,
          }
      );

      final response = await apiClient.post(
          endPoint,
          body: {
            "sentAndReceived": [
              PublishMessageHelper.settingsPayload(payload)
            ]}
      );
      mqttManager.publish(deviceId, PublishMessageHelper.settingsPayload(payload));
      if(response['code'] == 200){
        return true;
      }else{
        return false;
      }
    }catch (e){
      rethrow;
    }
  }

}