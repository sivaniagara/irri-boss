import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_urls.dart';

abstract class LocationRemoteDataSource {
  Future<Map<String, dynamic>> updateLocation({
    required int userId,
    required int controllerId,
    required String latLong,
  });
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final ApiClient apiClient;

  LocationRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> updateLocation({
    required int userId,
    required int controllerId,
    required String latLong,
  }) async {
    final endpoint = buildUrl(ApiUrls.updateLatLong, {
      'userId': userId,
      'controllerId': controllerId,
    });

    final response = await apiClient.put(
      endpoint,
      body: {'latLong': latLong},
    );
     return response;
  }
}
