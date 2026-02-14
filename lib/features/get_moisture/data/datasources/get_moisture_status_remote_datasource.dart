import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_client.dart';
import '../../utils/get_moisture_status_routes.dart';
import '../models/get_moisture_status_model.dart';

abstract class GetMoistureStatusRemoteDataSource {
  Future<GetMoistureStatusModel> getGetMoistureStatusData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}

class GetMoistureStatusRemoteDataSourceImpl implements GetMoistureStatusRemoteDataSource {
  final ApiClient apiClient;

  GetMoistureStatusRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<GetMoistureStatusModel> getGetMoistureStatusData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      String endpoint = NodeStatusUrls.getNodeStatusUrl
          .replaceAll(':userId', '$userId')
          .replaceAll(':subuserId', '$subuserId')
          .replaceAll(':controllerId', '$controllerId')
          .replaceAll(':fromDate', fromDate)
          .replaceAll(':toDate', toDate);

      final response = await apiClient.get(endpoint);

      if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty server response");
      }

      if (response["code"] == 200) {
        return GetMoistureStatusModel.fromJson(response);
      }

      throw ServerException(
        statusCode: response["code"],
        message: response["message"] ?? "Unknown error",
      );
    } catch (e) {
      throw ServerException(statusCode: 500, message: e.toString());
    }
  }
}
