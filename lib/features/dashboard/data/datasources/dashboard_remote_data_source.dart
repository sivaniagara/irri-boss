import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_urls.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_response_handler.dart';
import '../../domain/dashboard_domain.dart';
import '../../data/dashboard_data.dart';

abstract class DashboardRemoteDataSource {
  Future<List<GroupDetailsEntity>> fetchDashboardGroups(int userId);
  Future<List<ControllerEntity>> fetchControllers(int userId, int groupId);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<GroupDetailsEntity>> fetchDashboardGroups(int userId) async {
    try {
      final endpoint = DashboardUrls.dashboardForGroupUrl.replaceAll(':userId', userId.toString());
      final response = await apiClient.get(endpoint);
      return handleListResponse<GroupDetails>(
        response,
        fromJson: (json) => GroupDetails.fromJson(json),
      ).fold(
        (failure) => throw ServerException(message: failure.message),
        (groups) => groups.cast<GroupDetailsEntity>(),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ControllerEntity>> fetchControllers(int userId, int groupId) async {
    try {
      final endpoint = DashboardUrls.dashboardUrl.replaceAll(':userId', userId.toString()).replaceAll(':groupId', groupId.toString());
      final response = await apiClient.get(endpoint);
      return handleListResponse<ControllerModel>(
        response,
        fromJson: (json) => ControllerModel.fromJson(json),
      ).fold(
        (failure) => throw ServerException(message: failure.message),
        (controllers) => controllers.cast<ControllerEntity>(),
      );
    } catch (e, stackTrace) {
      print(stackTrace);
      print("Error :: $e");
      rethrow;
    }
  }

  Future<void> motorOnOff({
    required int userId,
    required int controllerId,
    required int subUserId,
    required String status,
    String? status2,
    required bool dualPump,
  }) async {
    try {

       final motorSms = status == "1" ? "MOTORON" : "MTROF";
      final motor2Sms = status == "1" ? "MOTOR1ON" : "MTROF";
      final sendsmsName = "${dualPump ? motor2Sms : motorSms}";
       final payload = {
        "status": status,
        "sentSms": sendsmsName,
      };

      // 3️⃣ Send API PUT request
      final endpoint = DashboardUrls.motorOnOffUrl
          .replaceAll(':userId', userId.toString())
          .replaceAll(':subuserId', subUserId.toString())
          .replaceAll(':controllerId', controllerId.toString());
      final response = await apiClient.put(endpoint,body: payload,);


      // 4️⃣ Handle response
      if (response.statusCode == 200) {
        print(response.data);

        // Optionally publish MQTT message here
        // MqttClient.publish(motorSms);
      } else {
        print("Failed to switch motor: ${response.data}");
      }
    } catch (e) {
      print("Error in motorOnOff: $e");
    }
  }

}