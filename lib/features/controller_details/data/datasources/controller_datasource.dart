import 'dart:convert';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/api_client.dart';
import '../../../../../core/utils/api_urls.dart';
import '../../domain/usecase/controller_details_params.dart';
import '../../domain/usecase/update_controllerDetails_params.dart';
import '../models/controller_details_model.dart';

import 'package:niagara_smart_drip_irrigation/core/utils/log.dart';
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
      final endpoint = ApiUrls.getViewControllerCustomerDetails
          .replaceAll(':userId', params.userId.toString())
          .replaceAll(':userDeviceId', params.controllerId.toString());

      kdebugmode("âž¡ï¸ GET API: $endpoint");

      final response = await apiClient.get(endpoint);

      kdebugmode("â¬…ï¸ GET RESPONSE: $response");

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
      kdebugmode("âŒ getControllerDetails ERROR: $e");
      throw ServerException(statusCode: 500, message: e.toString());
    }
  }

  //   NEW PUT UPDATE API
  @override
  Future<Map<String, dynamic>> updateController(
      UpdateControllerDetailsParams params) async {
    try {
      final endpoint = ApiUrls.updateController;

       // kdebugmode("âž¡ï¸ BODY: $body");
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

       kdebugmode(" ï¸ body RESPONSE: ${jsonEncode(body)}");
      final response = await apiClient.put(
        endpoint,
        body: body,
        headers: {
          "Content-Type": "application/json",
          "deviceType": "web",
        },
      );

      kdebugmode("â¬…ï¸ PUT RESPONSE: $response");

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
      kdebugmode("âŒ updateController ERROR: $e");
      kdebugmode("âŒ  error ${e.toString()}");
      throw ServerException(statusCode: 500, message: e.toString());
    }
  }
}


