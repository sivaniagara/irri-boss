import 'package:flutter/foundation.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/utils/irrigation_settings_urls.dart';

import '../../../../core/services/api_client.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/utils/api_urls.dart';

import 'package:niagara_smart_drip_irrigation/core/utils/log.dart';
abstract class IrrigationSettingsRemoteSource{
  Future <Map<String, dynamic>> getTemplateSetting({required Map<String, String> urlData});
  Future <Map<String, dynamic>> updateTemplateSetting({
    required Map<String, String> urlData,
    required String deviceId,
    required Map<String, dynamic> body
  });
}

class IrrigationSettingsRemoteSourceImpl extends IrrigationSettingsRemoteSource{
  final ApiClient apiClient;
  final MqttManager mqttManager;
  IrrigationSettingsRemoteSourceImpl({
    required this.apiClient,
    required this.mqttManager
  });

  @override
  Future<Map<String, dynamic>> getTemplateSetting(
      {required Map<String, String> urlData}) async{
    try{
      String endPoint = buildUrl(IrrigationSettingsUrls.getTemplateSetting, urlData);
      final response = await apiClient.get(endPoint);
      if(kDebugMode){
        kdebugmode('getTemplateSetting response  => $response');
      }
      return response;
    }catch (e){
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateTemplateSetting({
    required Map<String, String> urlData,
    required String deviceId,
    required Map<String, dynamic> body
  }) async{
    try{
      if(kDebugMode){
        kdebugmode("urlData : $urlData");
      }
      String endPoint = buildUrl(IrrigationSettingsUrls.updateTemplateSetting, urlData);
      final response = await apiClient.post(endPoint, body: body);
      if(kDebugMode){
        kdebugmode("deviceId :: $deviceId");
      }
      mqttManager.publish(deviceId, PublishMessageHelper.settingsPayload(body['sentSms']));
      if(kDebugMode){
        kdebugmode('updateTemplateSetting response  => $response');
      }
      return response;
    }catch (e){
      rethrow;
    }
  }

}