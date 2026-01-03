import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/utils/irrigation_settings_urls.dart';

import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_urls.dart';

abstract class IrrigationSettingsRemoteSource{
  Future <Map<String, dynamic>> getTemplateSetting({required Map<String, String> urlData});
}

class IrrigationSettingsRemoteSourceImpl extends IrrigationSettingsRemoteSource{
  final ApiClient apiClient;
  IrrigationSettingsRemoteSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getTemplateSetting(
      {required Map<String, String> urlData}) async{
    try{
      String endPoint = buildUrl(IrrigationSettingsUrls.templateSetting, urlData);
      final response = await apiClient.get(endPoint);
      print('getTemplateSetting response  => $response');
      return response;
    }catch (e){
      rethrow;
    }
  }

}