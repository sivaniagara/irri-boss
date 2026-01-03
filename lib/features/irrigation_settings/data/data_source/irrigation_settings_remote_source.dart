import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/utils/irrigation_settings_urls.dart';

import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_urls.dart';

abstract class IrrigationSettingsRemoteSource{
  Future <Map<String, dynamic>> getTemplateSetting({required Map<String, String> urlData});
  Future <Map<String, dynamic>> updateTemplateSetting({required Map<String, String> urlData, required Map<String, dynamic> body});
}

class IrrigationSettingsRemoteSourceImpl extends IrrigationSettingsRemoteSource{
  final ApiClient apiClient;
  IrrigationSettingsRemoteSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getTemplateSetting(
      {required Map<String, String> urlData}) async{
    try{
      String endPoint = buildUrl(IrrigationSettingsUrls.getTemplateSetting, urlData);
      final response = await apiClient.get(endPoint);
      print('getTemplateSetting response  => $response');
      return response;
    }catch (e){
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateTemplateSetting({required Map<String, String> urlData, required Map<String, dynamic> body}) async{
    try{
      print("urlData : ${urlData}");
      String endPoint = buildUrl(IrrigationSettingsUrls.updateTemplateSetting, urlData);
      final response = await apiClient.post(endPoint, body: body);
      print('updateTemplateSetting response  => $response');
      return response;
    }catch (e){
      rethrow;
    }
  }

}