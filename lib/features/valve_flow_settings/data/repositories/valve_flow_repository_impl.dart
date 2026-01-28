import 'dart:convert';
import 'package:dartz/dartz.dart';
<<<<<<< HEAD
import 'package:flutter/foundation.dart';
=======
<<<<<<< HEAD
>>>>>>> f53e4531667ac4c3711603ecda53aaef4b0adbda
import '../../../../core/error/failures.dart';
import '../data_sources/valve_flow_remote_source.dart';
import '../../domain/entities/valve_flow_entity.dart';
import '../../domain/repositories/valve_flow_repository.dart';
=======
import 'package:niagara_smart_drip_irrigation/features/valve_flow_settings/domain/repositories/valve_flow_repository.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/valve_flow_entity.dart';
import '../data_sources/valve_flow_remote_source.dart';

>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021

class ValveFlowRepositoryImpl implements ValveFlowRepository {
  final ValveFlowRemoteSource remoteSource;

  ValveFlowRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<Failure, ValveFlowEntity>> getValveFlowSetting({
    required String userId,
    required String controllerId,
    required String subUserId,
  }) async {
    try {
      final urlData = {
        'userId': userId,
        'controllerId': controllerId,
        'subUserId': subUserId,
      };

      final nodeList = await remoteSource.getNodeList(urlData: urlData);
      final valveFlowModel = await remoteSource.getValveFlowSetting(urlData: urlData);

      final updatedNodes = valveFlowModel.nodes.map((valveNode) {
        final matchingNode = nodeList.firstWhere(
<<<<<<< HEAD
              (n) => n['nodeId'].toString() == valveNode.nodeId,
          orElse: () => <String, dynamic>{},
        );
        if (matchingNode.isNotEmpty &&
            (valveNode.nodeName.isEmpty || valveNode.nodeName == 'Valve')) {
          return valveNode.copyWith(
              nodeName: matchingNode['nodeName']?.toString() ?? '');
=======
          (n) => n['nodeId'].toString() == valveNode.nodeId,
          orElse: () => null,
        );
        if (matchingNode != null && valveNode.nodeName.isEmpty) {
          return valveNode.copyWith(nodeName: matchingNode['nodeName']?.toString() ?? '');
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
        }
        return valveNode;
      }).toList();

      return Right(valveFlowModel.copyWith(nodes: updatedNodes));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
<<<<<<< HEAD
=======
  Future<Either<Failure, void>> publishValveFlowSms({
    required String userId,
    required String controllerId,
    required String subUserId,
    required String sentSms,
  }) async {
    try {
      // 1. Hardware command
      await remoteSource.publishMqttCommand(
        controllerId: controllerId,
        command: jsonEncode({"sentSms": sentSms}),
      );
      // 2. Status History Log
      await remoteSource.logHistory(
        userId: userId,
        subUserId: int.tryParse(subUserId) ?? 0,
        controllerId: controllerId,
        sentSms: sentSms,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
  Future<Either<Failure, void>> saveValveFlowSettings({
    required String userId,
    required String controllerId,
    required String subUserId,
    required ValveFlowEntity entity,
<<<<<<< HEAD
    required String sentSms,
  }) async {
    try {
      // 1. MQTT Publish (Critical for real-time control)
      // Determine the 15-digit Device ID for the MQTT topic
      String mqttDeviceId = entity.deviceId;

      // Fallback: Try to get it from the first node's QR Code if deviceId is empty
      if (mqttDeviceId.isEmpty && entity.nodes.isNotEmpty) {
        mqttDeviceId = entity.nodes.first.qrCode;
      }

      if (kDebugMode) {
        print("📤 VALVE FLOW MQTT ATTEMPT:");
        print("   Topic ID: $mqttDeviceId (length: ${mqttDeviceId.length})");
        print("   Payload: {\"sentSms\":\"$sentSms\"}");
      }

      if (mqttDeviceId.isNotEmpty) {
        await remoteSource.publishMqttCommand(
          controllerId: mqttDeviceId,
          command: jsonEncode({"sentSms": sentSms}),
        );
      } else {
        if (kDebugMode) print("⚠️ VALVE FLOW MQTT ABORTED: No valid 15-digit Device ID found.");
      }

      // 2. Log to history explicitly so it shows in the Dashboard's History box
      await remoteSource.logHistory(
        userId: userId,
        subuserId: subUserId,
        controllerId: controllerId,
        sentSms: sentSms,
      );

      // 3. Save to database (REST API Persistence)
      final int mId = entity.menuSettingId != 0 ? entity.menuSettingId : 488;
      final body = {
<<<<<<< HEAD
        "menuSettingId": mId,
=======
        "menuSettingId": 488,
        "receivedData": "",
        "sentSms": sentSms, // Single unified string (e.g. FLOWVALSET,001,22)
=======
  }) async {
    try {
      final endpoint = 'user/$userId/subuser/$subUserId/controller/$controllerId/menu/92/settings';
      
      Map<String, dynamic> templateJson = {};
      try {
        if (entity.templateJson.startsWith('{')) {
          templateJson = jsonDecode(entity.templateJson);
        } else {
          templateJson = {"FLOWPERCENT": "", "type": "52"};
        }
      } catch (_) {
        templateJson = {"FLOWPERCENT": "", "type": "52"};
      }
      
      templateJson['FLOWPERCENT'] = entity.flowDeviation;

      final body = {
        "menuSettingId": 488,
        "receivedData": "",
        "sentSms": "", 
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
        "templateJson": jsonEncode(templateJson),
>>>>>>> f53e4531667ac4c3711603ecda53aaef4b0adbda
        "sendData": jsonEncode(entity.nodes.map((n) => {
          "nodeName": n.nodeName,
          "nodeId": n.nodeId,
          "serialNo": n.serialNo,
          "nodeValue": n.nodeValue,
          "QRCode": n.qrCode,
          "flowDeviation": ""
        }).toList()),
        "receivedData": "",
        "sentSms": sentSms,
      };

<<<<<<< HEAD
      final endpoint = 'user/$userId/subuser/$subUserId/controller/$controllerId/menu/92/settings';
      await remoteSource.saveValveFlowSettings(endpoint: endpoint, body: body);

=======
<<<<<<< HEAD
      // 1. Save data to database (this handles the status log on the backend)
      await remoteSource.saveValveFlowSettings(endpoint: endpoint, body: body);

      // 2. Publish Hardware Command via MQTT for real-time sync
      await remoteSource.publishMqttCommand(
        controllerId: controllerId,
        command: jsonEncode({"sentSms": sentSms}),
      );

=======
      await remoteSource.saveValveFlowSettings(endpoint: endpoint, body: body);
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
>>>>>>> f53e4531667ac4c3711603ecda53aaef4b0adbda
      return const Right(null);
    } catch (e) {
      if (kDebugMode) print("❌ VALVE FLOW ERROR: $e");
      return Left(ServerFailure(e.toString()));
    }
  }
}
