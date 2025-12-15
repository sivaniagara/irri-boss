import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_urls.dart';
import '../../utils/senrev_routes.dart';
import '../models/sendrev_model.dart';


abstract class SendRevRemoteDataSource {
  Future<SendrevModel> getSendReceiveMessages({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}

class SendRevRemoteDataSourceImpl extends SendRevRemoteDataSource {
  final ApiClient apiClient;

  SendRevRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<SendrevModel> getSendReceiveMessages({
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
      String endpoint = SendRevPageUrls.getSendRevMsgUrl
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
        return SendrevModel.fromJson(response);
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
