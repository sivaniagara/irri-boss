import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_urls.dart';
import '../../utils/water_fertilizer_settings_url.dart';

abstract class WaterFertilizerSettingsRemoteSource{
  Future<Map<String, dynamic>> fetchProgramZoneSets({required Map<String, String> urlData});
  Future<Map<String, dynamic>> fetchZoneSetSettings({required Map<String, String> urlData});
}

class WaterFertilizerSettingsRemoteSourceImpl extends WaterFertilizerSettingsRemoteSource{
  final ApiClient apiClient;
  WaterFertilizerSettingsRemoteSourceImpl({required this.apiClient});


  @override
  Future<Map<String, dynamic>> fetchProgramZoneSets({required Map<String, String> urlData}) async{
    try{
      String endPoint = buildUrl(WaterFertilizerSettingsUrl.program, urlData);
      final response = await apiClient.get(endPoint);
      print('fetchProgramZoneSets response  => $response');
      return response;
    }catch (e){
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> fetchZoneSetSettings({required Map<String, String> urlData}) async{
    try{
      String endPoint = buildUrl(WaterFertilizerSettingsUrl.zoneSet, urlData);
      final response = await apiClient.get(endPoint);
      print('fetchZoneSetSettings response  => $response');
      return response;
    }catch (e){
      rethrow;
    }
  }
}