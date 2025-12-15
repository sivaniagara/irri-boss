import 'dart:convert';

import '../../../../../core/error/exceptions.dart';
import '../../../../../core/services/api_client.dart';
import '../../../../../core/utils/api_urls.dart';
import '../models/setserial_details_model.dart';

abstract class SetSerialDataSource {
  Future<String> sendSerial({
    required int userId,
    required int controllerId,
    required List<Map<String, dynamic>> sendList,
    required String sentSms,
  });

  Future<String> resetSerial({
    required int userId,
    required int controllerId,
    required List<int> nodeIds,
    required String sentSms,
  });

  Future<String> viewSerial({
    required int userId,
    required int controllerId,
    required String sentSms,
  });

  Future<List<SetSerialNodeList>> loadSerial({
    required int userId,
    required int controllerId,
  });
}


class SetSerialDataSourceImpl extends SetSerialDataSource {
  final ApiClient apiClient;

  SetSerialDataSourceImpl({required this.apiClient});

  // SEND SERIAL
  @override
  Future<String> sendSerial({
    required int userId,
    required int controllerId,
    required List<Map<String, dynamic>> sendList,
    required String sentSms,
  }) async {
    try {
      final endpoint = ApiUrls.postsetserialUrl
          .replaceAll(':userId', userId.toString())
          .replaceAll(':controllerId', controllerId.toString());

      final body = {
        "menuSettingId": 2,
        "sendData": sendList,
        "sentSms": sentSms,
        "receivedData": ""
      };

      print("➡️ POST URL: $endpoint");
      print("➡️ REQUEST BODY: ${jsonEncode(body)}");

      final response = await apiClient.post(
        endpoint,
        body: body,
        headers: {"Content-Type": "application/json", "deviceType": "web"},
      );

      print("⬅️ RESPONSE: $response");

      if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty server response");
      }

      if (response["code"] == 200) {
        return response["message"] ?? "Success";
      }

      throw ServerException(
        statusCode: response["code"] ?? 500,
        message: response["message"] ?? "Send serial failed",
      );
    } catch (e) {
      print("❌ sendSerial ERROR: $e");
      throw ServerException(statusCode: 500, message: e.toString());
    }
  }

  // RESET SERIAL
  @override
  Future<String> resetSerial({
    required int userId,
    required int controllerId,
    required List<int> nodeIds,
    required String sentSms,
  }) async {
    try {
      final endpoint = ApiUrls.putserialsetUrl
          .replaceAll(':userId', userId.toString())
          .replaceAll(':controllerId', controllerId.toString());

      final body = {
        "nodeList": nodeIds.map((id) => {"nodeId": id}).toList(),
        "sentSms": sentSms,
      };

      print("➡️ PUT URL: $endpoint");
      print("➡️ REQUEST BODY: ${jsonEncode(body)}");

      final response = await apiClient.put(
        endpoint,
        body: body,
        headers: {"Content-Type": "application/json", "deviceType": "web"},
      );

      print("⬅️ RESPONSE: $response");

      if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty server response");
      }

      if (response["code"] == 200) return response["message"];

      throw ServerException(
        statusCode: response["code"] ?? 500,
        message: response["message"] ?? "Reset failed",
      );
    } catch (e) {
      print("❌ resetSerial ERROR: $e");
      throw ServerException(statusCode: 500, message: e.toString());
    }
  }

  // VIEW SERIAL MESSAGE
  @override
  Future<String> viewSerial({
    required int userId,
    required int controllerId,
    required String sentSms,
  }) async {
    try {
      final endpoint = ApiUrls.postsetserialviewUrl
          .replaceAll(':userId', userId.toString())
          .replaceAll(':controllerId', controllerId.toString());

      print("➡️ POST URL: $endpoint");

      final response = await apiClient.post(
        endpoint,
        body: {"sentSms": sentSms},
        headers: {"Content-Type": "application/json", "deviceType": "web"},
      );

      print("⬅️ RESPONSE: $response");

      if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty server response");
      }

      if (response["code"] == 200) {
        return response["message"] ?? "";
      }

      throw ServerException(
        statusCode: response["code"] ?? 500,
        message: response["message"] ?? "View failed",
      );
    } catch (e) {
      print("❌ viewSerial ERROR: $e");
      throw ServerException(statusCode: 500, message: e.toString());
    }
  }
  @override
  Future<List<SetSerialNodeList>> loadSerial({
    required int userId,
    required int controllerId,
  }) async {
    try {
      // Build endpoint
      final endpoint = ApiUrls.getsetserialUrl
          .replaceAll(':userId', userId.toString())
          .replaceAll(':controllerId', controllerId.toString());

      // API CALL
      final response = await apiClient.get(endpoint);

      if (response == null) {
        throw ServerException(
          statusCode: 500,
          message: "Empty response from server",
        );
      }

      // Check response code
      final code = response["code"];
      if (code != 200) {
        throw ServerException(
          statusCode: code ?? 500,
          message: response["message"] ?? "Load serial failed",
        );
      }

      // Validate data
      final dataList = response["data"];
      if (dataList == null || dataList.isEmpty) {
        return []; // no records
      }

      final data = dataList[0];

      // Check for sendData availability
      final sendData = jsonDecode(data["sendData"]);
      if (sendData == null || sendData.toString().trim().isEmpty) {
        return [];
      }
      else if (!sendData.containsKey("nodeList")) {
        return [];
      }

      // Parse your model
      final model = SetSerialData.fromJson(sendData);

      return model.nodeList;
    } catch (e, stack) {
      print("❌ loadSerial ERROR: $e");
      print("STACK: $stack");
      throw ServerException(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }


  @override
  Future<List<SetSerialNodeList>> loadSeria1l({
    required int userId,
    required int controllerId,
  }) async {
    try {
      final endpoint = ApiUrls.getsetserialUrl
          .replaceAll(':userId', userId.toString())
          .replaceAll(':controllerId', controllerId.toString());

      final response = await apiClient.get(endpoint);

      if (response == null) {
        throw ServerException(statusCode: 500, message: "Empty response");
      }

      if (response["code"] == 200) {
        final data = response["data"][0];

        final model = SetSerialData.fromJson(data);

        if (data["sendData"] == null || data["sendData"] == "") {
          return []; // no serial found
        }

        return model.nodeList;
      }

      throw ServerException(
        statusCode: response["code"] ?? 500,
        message: response["message"] ?? "Load serial failed",
      );
    } catch (e) {
      print("❌ loadSerial ERROR: $e");
      throw ServerException(statusCode: 500, message: e.toString());
    }
  }

}
