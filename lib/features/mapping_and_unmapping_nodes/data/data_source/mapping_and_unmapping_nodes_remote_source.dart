import '../../../../core/services/api_client.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/utils/api_urls.dart';
import '../../utils/mapping_and_unmapping_nodes_urls.dart';

abstract class MappingAndUnmappingNodesRemoteSource{

  Future<Map<String, dynamic>> fetchMappingUnMappingNodeData({required Map<String, String> urlData});
  Future<Map<String, dynamic>> deleteMappedNode({required Map<String, String> urlData, required String deviceId});
  Future<Map<String, dynamic>> unmappedToMapped({required Map<String, String> urlData, required Map<String, dynamic> bodyData, required String deviceId});
  void viewNodeDetailsMqtt({required String deviceId, required String payload});
}



class MappingAndUnmappingNodesRemoteSourceImpl extends MappingAndUnmappingNodesRemoteSource{
  final ApiClient apiClient;
  final MqttManager mqttManager;
  MappingAndUnmappingNodesRemoteSourceImpl({
    required this.apiClient,
    required this.mqttManager,
  });

  @override
  Future<Map<String, dynamic>> fetchMappingUnMappingNodeData({required Map<String, String> urlData}) async{
    try{
      String endPoint = buildUrl(MappingAndUnmappingNodesUrls.getMappingAndUnmappingNode, urlData);
      final response = await apiClient.get(endPoint);
      print('fetchMappingUnMappingNodeData response  => $response');
      return response;
    }catch (e){
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> deleteMappedNode({required Map<String, String> urlData, required String deviceId}) async{
    try{
      String endPoint = buildUrl(MappingAndUnmappingNodesUrls.deleteMappedNode, urlData);
      final response = await apiClient.delete(endPoint);
      mqttManager.publish(deviceId, PublishMessageHelper.settingsPayload(urlData['payload']!));
      return response;
    }catch (e){
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> unmappedToMapped({
    required Map<String, String> urlData,
    required Map<String, dynamic> bodyData,
    required String deviceId
  }) async{
    try{
      String endPoint = buildUrl(MappingAndUnmappingNodesUrls.unMappedToMapped, urlData);
      final response = await apiClient.post(endPoint, body: bodyData);
      print('unmappedToMapped response  => $response');
      for(var node in bodyData['nodeList']){
        mqttManager.publish(deviceId, PublishMessageHelper.settingsPayload(node['sentSms']));
      }
      return response;
    }catch (e){
      rethrow;
    }
  }

  @override
  void viewNodeDetailsMqtt({required String deviceId, required String payload}) {
    mqttManager.publish(deviceId, PublishMessageHelper.settingsPayload(payload));
  }
}
