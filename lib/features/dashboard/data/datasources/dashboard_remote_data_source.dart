import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/api_urls.dart';
import 'package:niagara_smart_drip_irrigation/core/utils/common_toast.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/utils/dashboard_urls.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_routes.dart';
import 'package:niagara_smart_drip_irrigation/features/dealer_dashboard/utils/dealer_urls.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/api_client.dart';
import '../../../../core/services/mqtt/mqtt_manager.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../../../core/utils/api_response_handler.dart';
import '../../domain/dashboard_domain.dart';
import '../../data/dashboard_data.dart';

abstract class DashboardRemoteDataSource {
  Future<List<GroupDetailsEntity>> fetchDashboardGroups(int userId, GoRouterState routeState);
  Future<List<ControllerEntity>> fetchControllers(int userId, int groupId, GoRouterState routeState);
  Future<void> motorOnOff({required int userId, required int controllerId, required String deviceId, required int subUserId, required String status, required bool dualPump,
  });
  Future<bool> changeFrom({
    required String userId,
    required String controllerId,
    required String programId,
    required String deviceId,
    required String payload,
  });
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient apiClient;

  DashboardRemoteDataSourceImpl({
    required this.apiClient,
  });

  @override
  Future<List<GroupDetailsEntity>> fetchDashboardGroups(int userId, GoRouterState routeState) async {
    try {
      final endpoint = buildUrl(DashboardUrls.dashboardForGroupUrl, {'userId': userId});
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
  Future<List<ControllerEntity>> fetchControllers(int userId, int groupId, GoRouterState routeState) async {
    try {
      final extra = routeState.extra != null ? routeState.extra as Map<String, dynamic> : {};
      final queryParams = routeState.uri.queryParameters as Map<String, dynamic>;
      String endpoint = buildUrl(DashboardUrls.dashboardUrl, {'userId': userId, 'groupId': groupId});
      if(extra.containsKey('name') && extra['name'] != DashBoardRoutes.dashboard) {
        if(extra['name'] == DealerRoutes.sharedDevice) {
          endpoint = buildUrl(DealerUrls.getCustomerSharedDevice, {'userId': queryParams['userId'], 'dealerId': queryParams['dealerId']});
        }
        endpoint = buildUrl(DealerUrls.getDealerCustomerDeviceDetails, {'userId': queryParams['userId'], 'dealerId': queryParams['dealerId']});
      }
      final response = await apiClient.get(endpoint);
      for(var i in response['data']){
        print("controller response => $i");
      }
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
    print("payload:$payload");

    final endpoint = DashboardUrls.motorOnOffUrl
        .replaceAll(':userId', userId.toString())
        .replaceAll(':subuserId', subUserId.toString())
        .replaceAll(':controllerId', controllerId.toString());

    final response = await apiClient.put(endpoint, body: payload);

    if (response['code'] != 200) {
      showToast(response['message'],backgroundColor: Colors.red,textColor: Colors.white);
      throw ServerException(message: "Motor switch failed");
    }
    showToast(response['message'],backgroundColor: Colors.green,textColor: Colors.white);

  }

  @override
  Future<bool> changeFrom({
    required String userId,
    required String controllerId,
    required String programId,
    required String deviceId,
    required String payload
  }) async{
    try{
      String endPoint = buildUrl(
        DashboardUrls.sentAndReceive,
        {
          'userId': userId,
          'controllerId': controllerId,
          'programId': programId,
        }
      );

      final response = await apiClient.post(
          endPoint,
          body: {
            "sentAndReceived": [
              PublishMessageHelper.settingsPayload(payload)
          ]}
      );
      // mqttManager.publish(deviceId, payload);
      await Future.delayed(Duration(seconds: 3));
      return true;
    }catch (e){
      rethrow;
    }
  }
}