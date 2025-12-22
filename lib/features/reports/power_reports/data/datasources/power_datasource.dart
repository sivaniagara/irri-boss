import 'dart:convert';
import 'package:http/http.dart' as http;


import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/services/api_client.dart';
import '../../utils/Power_routes.dart';
import '../models/power_model.dart';

abstract class PowerRemoteDataSource {
  Future<PowerGraphModel> PowergraphData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
    required int sum,
  });
}

class PowerRemoteDataSourceImpl extends PowerRemoteDataSource {
  final ApiClient apiClient;

  PowerRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PowerGraphModel> PowergraphData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
    required int sum,
  }) async {
    try {
      /// Validate required params
      if (fromDate.isEmpty || toDate.isEmpty) {
        throw ServerException(
          statusCode: 400,
          message: "Invalid parameters! One or more values missing.",
        );
      }

      /// Build endpoint URL
      String endpoint = PowerGraphPageUrls.getPowerGraphUrl
          .replaceAll(':userId', '$userId')
          .replaceAll(':subuserId', '$subuserId')
          .replaceAll(':controllerId', '$controllerId')
          .replaceAll(':fromDate', fromDate)
          .replaceAll(':toDate', toDate)
          .replaceAll(':sum', '$sum');


      /// Make API call
      final response = await apiClient.get(endpoint);
       print("endpoint--->$endpoint");

      if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty server response");
      }

      /// Success Response
      if (response["code"] == 200) {
        return PowerGraphModel.fromJson(response);
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
