import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/features/valve_flow_settings/domain/repositories/valve_flow_repository.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/valve_flow_entity.dart';
import '../data_sources/valve_flow_remote_source.dart';


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
          orElse: () => null,
        );
        if (matchingNode != null && valveNode.nodeName.isEmpty) {
          return valveNode.copyWith(nodeName: matchingNode['nodeName']?.toString() ?? '');
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
  Future<Either<Failure, void>> saveValveFlowSettings({
    required String userId,
    required String controllerId,
    required String subUserId,
    required ValveFlowEntity entity,
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
        "templateJson": jsonEncode(templateJson),
        "sendData": jsonEncode(entity.nodes.map((n) => {
          "nodeName": n.nodeName,
          "nodeId": n.nodeId,
          "serialNo": n.serialNo,
          "nodeValue": n.nodeValue,
          "QRCode": n.qrCode,
          "flowDeviation": entity.flowDeviation
        }).toList())
      };

      await remoteSource.saveValveFlowSettings(endpoint: endpoint, body: body);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
