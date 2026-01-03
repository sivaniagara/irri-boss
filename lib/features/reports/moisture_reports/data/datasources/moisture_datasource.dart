
import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/services/api_client.dart';
import '../../utils/moisture_routes.dart';
import '../models/moisture_model.dart';

abstract class MoistureRemoteDataSource {
  Future<MoistureModel> MoistureData({
    required int userId,
    required int subuserId,
    required int controllerId,
  });
}

class MoistureRemoteDataSourceImpl extends MoistureRemoteDataSource {
  final ApiClient apiClient;

  MoistureRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MoistureModel> MoistureData({
    required int userId,
    required int subuserId,
    required int controllerId,
   }) async {
    try {
      /// Validate required params

      /// Build endpoint URL
      String endpoint = MoistureReportPageUrls.getMoistureUrl
          .replaceAll(':userId', '$userId')
          .replaceAll(':subuserId', '$subuserId')
          .replaceAll(':controllerId', '$controllerId');

      /// Make API call
      final response = await apiClient.get(endpoint);
       print("endpoint--->$endpoint");

      if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty server response");
      }

      /// Success Response
      if (response["code"] == 200) {
        return MoistureModel.fromJson(response);
      }

      /// Error Response
      throw ServerException(
        statusCode: response["code"],
        message: response["message"] ?? "Unknown error in sendrev API",
      );
    } catch (e) {
        throw ServerException(statusCode: 500, message: e.toString());
    }
  }
}
