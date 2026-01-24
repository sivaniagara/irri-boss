import 'dart:convert';

import '../../../../core/services/api_client.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/utils/api_urls.dart';
import '../../utils/edit_program_urls.dart';

abstract class EditProgramRemoteSource{
  Future<Map<String, dynamic>> getPrograms({required Map<String, String> urlData});
  Future<bool> sendZonePayload({
    required Map<String, String> urlData,
    required Map<String, dynamic> bodyData,
    required List<Map<String, dynamic>> listOfPayload,
    required String deviceId
  });
}


class EditProgramRemoteSourceImpl extends EditProgramRemoteSource{
  final ApiClient apiClient;
  final MqttManager mqttManager;
  EditProgramRemoteSourceImpl({
    required this.apiClient,
    required this.mqttManager,
  });

  @override
  Future<Map<String, dynamic>> getPrograms({required Map<String, String> urlData})async {
    try{
      print('getPrograms => ${urlData}');
      String endPoint = buildUrl(EditProgramUrls.getProgram, urlData);
      final response = await apiClient.get(endPoint);
      print('getPrograms => $response');
      return response;
    }catch (e){
      rethrow;
    }
  }

  @override
  Future<bool> sendZonePayload({
    required Map<String, String> urlData,
    required Map<String, dynamic> bodyData,
    required List<Map<String, dynamic>> listOfPayload,
    required String deviceId,
  })async {
    try{
      String endPoint = buildUrl(EditProgramUrls.sentAndReceive, urlData);
      await Future.delayed(Duration(seconds: 3));
      final response = await apiClient.post(
          endPoint,
        body: {"sentAndReceived": listOfPayload}
      );
      print('getPrograms => $response');
      for(var payload in listOfPayload){
        mqttManager.publish(deviceId, payload);
      }
      return true;
    }catch (e){
      rethrow;
    }
  }
}