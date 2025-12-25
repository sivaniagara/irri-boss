import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/utils/motor_cyclic_routes.dart';


import '../../../../../../core/error/exceptions.dart';
import '../../../../../../core/services/api_client.dart';
import '../../utils/tdy_valve_status_routes.dart';
import '../models/tdy_valve_status_model.dart';


abstract class TdyValveStatusRemoteDataSource {
  Future<TdyValveStatusModel> TdyValveStatusData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String program,
  });
}

class TdyValveStatusRemoteDataSourceImpl extends TdyValveStatusRemoteDataSource {
  final ApiClient apiClient;

  TdyValveStatusRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TdyValveStatusModel> TdyValveStatusData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String program,
  }) async {
    try {
      /// Validate required params
      if (fromDate.isEmpty ) {
        throw ServerException(
          statusCode: 400,
          message: "Invalid parameters! One or more values missing.",
        );
      }

      /// Build endpoint URL
      String endpoint = TdyValveStatusPageUrls.getTdyValveStatusUrl
          .replaceAll(':userId', '$userId')
          .replaceAll(':subuserId', '$subuserId')
          .replaceAll(':controllerId', '$controllerId')
          .replaceAll(':fromDate', fromDate)
          .replaceAll(':program', program);

      /// Make API call
      final response = await apiClient.get(endpoint);
       print("endpoint--->$endpoint");

      if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty server response");
      }

      /// Success Response
      if (response["code"] == 200) {
        return TdyValveStatusModel.fromJson(response);
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
