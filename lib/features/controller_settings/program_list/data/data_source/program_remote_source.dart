// data/sources/program_remote_source.dart
import 'package:niagara_smart_drip_irrigation/core/utils/api_urls.dart';
import 'package:niagara_smart_drip_irrigation/features/controller_settings/utils/controller_settings_urls.dart';

import '../../../../../core/services/api_client.dart';

abstract class ProgramRemoteSource {
  Future<Map<String, dynamic>> getPrograms(Map<String, String> data);
}


class ProgramRemoteSourceImplements extends ProgramRemoteSource{
  final ApiClient apiClient;
  ProgramRemoteSourceImplements({required this.apiClient});

  @override
  Future<Map<String, dynamic>> getPrograms(Map<String, String> data) async{
    try{
      print('ProgramRemoteSourceImplements');
      String endpoint = buildUrl(ControllerSettingsUrls.getProgram, data);
      final response = await apiClient.get(endpoint);
      print('getPrograms => $response');
      return response;
    }catch (e){
      rethrow;
    }
  }

}
