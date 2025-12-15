import 'dart:convert';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/api_client.dart';
import '../../../../../core/utils/api_urls.dart';
import '../../domain/entities/controller_details_entities.dart';
import '../../domain/usecase/controller_details_params.dart';
import '../../domain/usecase/update_controllerDetails_params.dart';
import '../models/controller_details_model.dart';

abstract class ControllerRemoteDataSource {
  Future<ControllerResponseModel> getControllerDetails(
      GetControllerDetailsParams params);
  Future<Map<String, dynamic>> updateController(UpdateControllerDetailsParams params);
 }

class ControllerRemoteDataSourceImpl extends ControllerRemoteDataSource {
  final ApiClient apiClient;

  ControllerRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<ControllerResponseModel> getControllerDetails(
      GetControllerDetailsParams params) async {
    try {
      if (params.userId == null || params.controllerId == null) {
        throw ServerException(
          statusCode: 400,
          message: "Invalid parameters! userId/controllerId missing.",
        );
      }

      final endpoint = ApiUrls.getViewControllerCustomerDetails
          .replaceAll(':userId', params.userId.toString())
          .replaceAll(':userDeviceId', params.controllerId.toString());

      print("➡️ GET API: $endpoint");

      final response = await apiClient.get(endpoint);

      print("⬅️ GET RESPONSE: $response");

      if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty server response");
      }

      if (response['code'] == 200) {
        return ControllerResponseModel.fromJson(response);
      }

      throw ServerException(
        statusCode: response['code'],
        message: response['message'] ?? "Unknown server error",
      );
    } catch (e) {
      print("❌ getControllerDetails ERROR: $e");
      throw ServerException(statusCode: 500, message: e.toString());
    }
  }

  //   NEW PUT UPDATE API
  @override
  Future<Map<String, dynamic>> updateController(
      UpdateControllerDetailsParams params) async {
    try {
      final endpoint = ApiUrls.updateController;

       // print("➡️ BODY: $body");
      Map<String, dynamic> body = {
        "userId" : params.userId,
        "userDeviceId" : params.controllerId,
        "countryCode" : params.countryCode,
        "simNumber" : params.simNumber,
        "deviceName" : params.deviceName,
        "groupId" : params.groupId,
        "operationMode" : params.operationMode,
        "gprsMode" : params.gprsMode,
        "appSmsMode" : params.appSmsMode,
        "sentSms" : params.sentSms,
        "editType" : params.editType
      };

       print(" ️ body RESPONSE: ${jsonEncode(body)}");
      final response = await apiClient.put(
        endpoint,
        body: body,
        headers: {
          "Content-Type": "application/json",
          "deviceType": "web",
        },
      );

      print("⬅️ PUT RESPONSE: $response");

      if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty server response");
      }

      if (response["code"] == 200) {
        return response;
      }

      throw ServerException(
        statusCode: response["code"] ?? 500,
        message: response["message"] ?? "Update failed",
      );
    } catch (e) {
      print("❌ updateController ERROR: $e");
      print("❌  error ${e.toString()}");
      throw ServerException(statusCode: 500, message: e.toString());
    }
  }
}


