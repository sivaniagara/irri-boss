import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_urls.dart';
import '../models/service_request_model.dart';

abstract class ServiceRequestRemoteDataSource {
  Future<List<ServiceRequestModel>> getServiceRequests(String userId);
  Future<void> updateServiceRequest({
    required String dealerId,
    required String serviceRequestId,
    required String status,
    required String remark,
    required String userId,
    required String controllerId,
    required String sentSms,
  });
}

class ServiceRequestRemoteDataSourceImpl implements ServiceRequestRemoteDataSource {
  final ApiClient apiClient;

  ServiceRequestRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ServiceRequestModel>> getServiceRequests(String userId) async {
    final url = buildUrl(ApiUrls.getServiceRequestList, {'userId': userId});
    try {
      final response = await apiClient.get(url);
      if (response['code'] == 200) {
        final List<dynamic> data = response['data'];
        return data.map((json) => ServiceRequestModel.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load service requests');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateServiceRequest({
    required String dealerId,
    required String serviceRequestId,
    required String status,
    required String remark,
    required String userId,
    required String controllerId,
    required String sentSms,
  }) async {
    final url = buildUrl(ApiUrls.updateService, {'userId': dealerId});
    final body = {
      "serviceRequest": [
        {
          "serviceReqId": serviceRequestId,
          "serviceStatus": status,
          "remark": remark,
          "userId": userId,
          "controllerId": controllerId,
          "sentSms": sentSms
        }
      ]
    };
    try {
      final response = await apiClient.put(url, body: body);
      if (response['code'] != 200) {
        throw Exception(response['message'] ?? 'Failed to update service request');
      }
    } catch (e) {
      rethrow;
    }
  }
}
