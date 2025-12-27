import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/utils/motor_cyclic_routes.dart';


import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/services/api_client.dart';
import '../models/motor_cyclic_model.dart';

abstract class MotorCyclicRemoteDataSource {
  Future<MotoCyclicModel> MotorCyclicData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}

class MotorCyclicRemoteDataSourceImpl extends MotorCyclicRemoteDataSource {
  final ApiClient apiClient;

  MotorCyclicRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MotoCyclicModel> MotorCyclicData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
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
      String endpoint = MotorCyclicPageUrls.getMotorCyclicUrl
          .replaceAll(':userId', '$userId')
          .replaceAll(':subuserId', '$subuserId')
          .replaceAll(':controllerId', '$controllerId')
          .replaceAll(':fromDate', fromDate)
          .replaceAll(':toDate', toDate);

      /// Make API call
      final response = await apiClient.get(endpoint);
       print("endpoint--->$endpoint");

      if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty server response");
      }

      /// Success Response
      if (response["code"] == 200) {
        return MotoCyclicModel.fromJson(response);
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
