import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/api_client.dart';
import '../../utils/flow_graph_routes.dart';
import '../models/flow_graph_model.dart';

abstract class FlowGraphRemoteDataSource {
  Future<FlowGraphModel> FlowGraphData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}

class FlowGraphRemoteDataSourceImpl extends FlowGraphRemoteDataSource {
  final ApiClient apiClient;

  FlowGraphRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<FlowGraphModel> FlowGraphData({
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
      String endpoint = FlowGraphPageUrls.getFlowGraphUrl
          .replaceAll(':userId', '$userId')
          .replaceAll(':subuserId', '$subuserId')
          .replaceAll(':controllerId', '$controllerId')
          .replaceAll(':fromDate', fromDate)
          .replaceAll(':toDate', toDate);


      /// Make API call
      final response = await apiClient.get(endpoint);


      if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty server response");
      }

      /// Success Response
      if (response["code"] == 200) {
        return FlowGraphModel.fromJson(response);
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
