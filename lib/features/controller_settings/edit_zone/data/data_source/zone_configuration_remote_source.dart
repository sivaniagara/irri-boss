
import '../../../../../core/services/api_client.dart';
import '../../../../../core/utils/api_urls.dart';
import '../../../utils/controller_settings_urls.dart';
import '../../domain/entities/zone_nodes_entity.dart';

abstract class ZoneConfigurationRemoteSource{
  Future<Map<String, dynamic>> getZoneConfiguration(Map<String, String> data);
  Future<Map<String, dynamic>> submitZoneConfiguration({
    required Map<String, dynamic> body,
    required Map<String, String> urlData,
  });
  Future<Map<String, dynamic>> editZoneConfiguration(Map<String, String> data);
}

class ZoneConfigurationRemoteSourceImpl extends ZoneConfigurationRemoteSource{
  final ApiClient apiClient;
  ZoneConfigurationRemoteSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getZoneConfiguration(Map<String, String> data) async{
    try{
      String endpoint = buildUrl(ControllerSettingsUrls.addZone, data);
      final response = await apiClient.get(endpoint);
      return response;
    }catch (e){
      print('getZoneConfiguration error in data source impl : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> submitZoneConfiguration({
    required Map<String, dynamic> body,
    required Map<String, String> urlData,
  }) async{
    try{
      print("body => ${body} == urlData => ${urlData}");
      String endpoint = buildUrl(ControllerSettingsUrls.submitZone, urlData);
      final response = await apiClient.post(endpoint, body: body);
      return response;
    }catch (e){
      print('getZoneConfiguration error in data source impl : ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> editZoneConfiguration(Map<String, String> data) async{
    try{
      String endpoint = buildUrl(ControllerSettingsUrls.editZone, data);
      final response = await apiClient.get(endpoint);
      return response;
    }catch (e){
      print('getZoneConfiguration error in data source impl : ${e.toString()}');
      rethrow;
    }
  }

}