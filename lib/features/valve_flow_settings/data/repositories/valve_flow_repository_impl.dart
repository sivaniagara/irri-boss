import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/error/failures.dart';
import '../data_sources/valve_flow_remote_source.dart';
import '../../domain/entities/valve_flow_entity.dart';
import '../../domain/repositories/valve_flow_repository.dart';

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
          (n) => n['nodeId'].toString() == valveNode.nodeId,
          orElse: () => <String, dynamic>{},
        );
        if (matchingNode.isNotEmpty &&
            (valveNode.nodeName.isEmpty || valveNode.nodeName == 'Valve')) {
          return valveNode.copyWith(
              nodeName: matchingNode['nodeName']?.toString() ?? '');
        }
        return valveNode;
      }).toList();

      return Right(valveFlowModel.copyWith(nodes: updatedNodes));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> publishValveFlowSms({
    required String userId,
    required String controllerId,
    required String subUserId,
    required String sentSms,
  }) async {
    try {
      await remoteSource.publishMqttCommand(
        controllerId: controllerId,
        command: jsonEncode({"sentSms": sentSms}),
      );
      await remoteSource.logHistory(
        userId: userId,
        subuserId: subUserId,
        controllerId: controllerId,
        sentSms: sentSms,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveValveFlowSettings({
    required String userId,
    required String controllerId,
    required String subUserId,
    required ValveFlowEntity entity,
    required String sentSms,
  }) async {
    try {
      String mqttDeviceId = entity.deviceId;
      if (mqttDeviceId.isEmpty && entity.nodes.isNotEmpty) {
        mqttDeviceId = entity.nodes.first.qrCode;
      }

      if (mqttDeviceId.isNotEmpty) {
        await remoteSource.publishMqttCommand(
          controllerId: mqttDeviceId,
          command: jsonEncode({"sentSms": sentSms}),
        );
      }

      await remoteSource.logHistory(
        userId: userId,
        subuserId: subUserId,
        controllerId: controllerId,
        sentSms: sentSms,
      );

      final int mId = entity.menuSettingId != 0 ? entity.menuSettingId : 488;
      final body = {
        "menuSettingId": mId,
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

      final endpoint = 'user/$userId/subuser/$subUserId/controller/$controllerId/menu/92/settings';
      await remoteSource.saveValveFlowSettings(endpoint: endpoint, body: body);

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
