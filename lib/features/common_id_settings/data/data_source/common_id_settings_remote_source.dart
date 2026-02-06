
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_urls.dart';
import '../../../program_settings/utils/program_settings_urls.dart';
import '../../utils/common_id_settings_urls.dart';

abstract class CommonIdSettingsRemoteSource{
  Future<Map<String, dynamic>> getCommonIdSettings(Map<String, String> data);
  Future<Map<String, dynamic>> updateCategoryNodeSerialNo({required Map<String, String> urlData, required Map<String, dynamic> body});
}

class CommonIdSettingsDataSourceImpl extends CommonIdSettingsRemoteSource{
  final ApiClient apiClient;
  CommonIdSettingsDataSourceImpl({required this.apiClient});

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

}