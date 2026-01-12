import '../../../../core/services/api_client.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/utils/api_urls.dart';
import '../../utils/edit_program_urls.dart';

abstract class EditProgramRemoteSource{
  Future<Map<String, dynamic>> getPrograms({required Map<String, String> urlData});
  Future<bool> sendZoneConfigurationPayload({
    required Map<String, String> urlData,
    required Map<String, dynamic> bodyData,
    required List<String> listOfPayload,
    required String deviceId
  });
  Future<bool> sendZoneSetPayload({
    required Map<String, String> urlData,
    required Map<String, dynamic> bodyData,
    required List<String> listOfPayload,
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
      print('getPrograms');
      String endPoint = buildUrl(EditProgramUrls.getProgram, urlData);
      final response = await apiClient.get(endPoint);
      print('getPrograms => $response');
      return response;
    }catch (e){
      rethrow;
    }
  }

  @override
  Future<bool> sendZoneConfigurationPayload({
    required Map<String, String> urlData,
    required Map<String, dynamic> bodyData,
    required List<String> listOfPayload,
    required String deviceId,
  })async {
    try{
      // String endPoint = buildUrl(EditProgramUrls.getProgram, urlData);
      // final response = await apiClient.get(endPoint);
      // print('getPrograms => $response');
      mqttManager.publish(deviceId, listOfPayload[0]);
      mqttManager.publish(deviceId, listOfPayload[1]);
      return true;
    }catch (e){
      rethrow;
    }
  }

  @override
  Future<bool> sendZoneSetPayload({
    required Map<String, String> urlData,
    required Map<String, dynamic> bodyData,
    required List<String> listOfPayload,
    required String deviceId
  }) async {
    try{
      // String endPoint = buildUrl(EditProgramUrls.getProgram, urlData);
      // final response = await apiClient.get(endPoint);
      // print('getPrograms => $response');
      mqttManager.publish(deviceId, listOfPayload[0]);
      mqttManager.publish(deviceId, listOfPayload[1]);
      return true;
    }catch (e){
      rethrow;
    }
  }

}