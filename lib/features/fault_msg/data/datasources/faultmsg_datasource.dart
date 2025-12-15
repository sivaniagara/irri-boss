import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_urls.dart';
import '../../utils/faultmsg_routes.dart';
import '../models/faultmsg_model.dart';


abstract class faultmsgRemoteDataSource {
  Future<FaultMsgModel> getFaultMessages({
    required int userId,
    required int subuserId,
    required int controllerId,
   });
}

class faultmsgRemoteDataSourceImpl extends faultmsgRemoteDataSource {
  final ApiClient apiClient;

  faultmsgRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<FaultMsgModel> getFaultMessages({
    required int userId,
    required int subuserId,
    required int controllerId,
   }) async {
    try {
      /// Validate required params
      if (userId == null) {
        throw ServerException(
          statusCode: 400,
          message: "Invalid parameters! One or more values missing.",
        );
      }

      /// Build endpoint URL
      String endpoint = FaultMsgPageUrls.getFaultMsgMsgUrl
          .replaceAll(':userId', '$userId')
          .replaceAll(':subuserId', '$subuserId')
          .replaceAll(':controllerId', '$controllerId');

       /// Make API call
      final response = await apiClient.get(endpoint);

       if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty server response");
      }
       /// Success Response
      if (response["code"] == 200) {
        return FaultMsgModel.fromJson(response);
      }
       /// Error Response
      throw ServerException(
        statusCode: response["code"],
        message: response["message"] ?? "Unknown error in faultmsg API",
      );
    } catch (e) {
      print("❌ getSendReceiveMessages ERROR: ${e.toString()}");
      throw ServerException(statusCode: 500, message: e.toString());
    }
  }
}
