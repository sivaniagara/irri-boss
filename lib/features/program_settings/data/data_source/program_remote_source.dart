// data/sources/program_remote_source.dart
import 'package:niagara_smart_drip_irrigation/core/utils/api_urls.dart';

import '../../../../core/services/api_client.dart';
import '../../utils/program_settings_urls.dart';

abstract class ProgramRemoteSource {
  Future<Map<String, dynamic>> getPrograms(Map<String, String> data);
  Future<Map<String, dynamic>> deleteZone(Map<String, String> urlData);
}


class ProgramRemoteSourceImplements extends ProgramRemoteSource{
  final ApiClient apiClient;
  ProgramRemoteSourceImplements({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getPrograms(Map<String, String> data) async{
    try{
      print('ProgramRemoteSourceImplements');
      String endPoint = buildUrl(ProgramSettingsUrls.getProgram, data);
      final response = await apiClient.get(endPoint);
      print('getPrograms => $response');
      return response;
    }catch (e){
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> deleteZone(Map<String, String> urlData)async{
    try{
      String endPoint = buildUrl(ProgramSettingsUrls.deleteZone, urlData);
      final response = await apiClient.delete(endPoint);
      print('delete zone => $response');
      return response;
    }catch(e){
      rethrow;
    }
  }

}
