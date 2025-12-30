import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_urls.dart';
import '../../utils/mapping_and_unmapping_nodes_urls.dart';

abstract class MappingAndUnmappingNodesRemoteSource{

  Future<Map<String, dynamic>> fetchMappingUnMappingNodeData({required Map<String, String> urlData});
  Future<Map<String, dynamic>> deleteMappedNode({required Map<String, String> urlData});
  Future<Map<String, dynamic>> unmappedToMapped({required Map<String, String> urlData, required Map<String, dynamic> bodyData});
}



class MappingAndUnmappingNodesRemoteSourceImpl extends MappingAndUnmappingNodesRemoteSource{
  final ApiClient apiClient;
  MappingAndUnmappingNodesRemoteSourceImpl({required this.apiClient});

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
  Future<Map<String, dynamic>> deleteMappedNode({required Map<String, String> urlData}) async{
    try{
      String endPoint = buildUrl(MappingAndUnmappingNodesUrls.deleteMappedNode, urlData);
      final response = await apiClient.delete(endPoint);
      print('deleteMappedNode response  => $response');
      return response;
    }catch (e){
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> unmappedToMapped({required Map<String, String> urlData, required Map<String, dynamic> bodyData}) async{
    try{
      String endPoint = buildUrl(MappingAndUnmappingNodesUrls.unMappedToMapped, urlData);
      print("bodyData : ${bodyData}");
      final response = await apiClient.post(endPoint, body: bodyData);
      print('unmappedToMapped response  => $response');
      return response;
    }catch (e){
      rethrow;
    }
  }
}


