import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_urls.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/utils/api_response_handler.dart';
import '../../domain/dashboard_domain.dart';
import '../../data/dashboard_data.dart';

abstract class DashboardRemoteDataSource {
  Future<List<GroupDetailsEntity>> fetchDashboardGroups(int userId, GoRouterState routeState);
  Future<List<ControllerEntity>> fetchControllers(int userId, int groupId);
  Future<void> motorOnOff({required int userId, required int controllerId, required String deviceId, required int subUserId, required String status, required bool dualPump,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<GroupDetailsEntity>> fetchDashboardGroups(int userId, GoRouterState routeState) async {
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

  @override
  Future<void> motorOnOff({
    required int userId,
    required int controllerId,
    required int subUserId,
    required String status,
    required String deviceId,
     String? status2,
    required bool dualPump,
  }) async {
    final motorSms = status == "1" ? "MOTORON" : "MTROF";
    final motor2Sms = status2 == "1" ? "MOTOR1ON" : "MTROF";
    final sendsmsName = dualPump ? motor2Sms : motorSms;

    final payload = {
      "status": status,
      "sentSms": sendsmsName,
    };

    final endpoint = DashboardUrls.motorOnOffUrl
        .replaceAll(':userId', userId.toString())
        .replaceAll(':subuserId', subUserId.toString())
        .replaceAll(':controllerId', controllerId.toString());

    final response = await apiClient.put(endpoint, body: payload);

    if (response.statusCode != 200) {
      throw ServerException(message: "Motor switch failed");
    }
  }
}