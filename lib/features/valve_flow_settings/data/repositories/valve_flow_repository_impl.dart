import 'dart:convert';
import 'package:dartz/dartz.dart';
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
  Future<Either<Failure, void>> saveValveFlowSettings({
    required String userId,
    required String controllerId,
    required String subUserId,
    required ValveFlowEntity entity,
    required String sentSms,
  }) async {
    try {
      // Endpoint for settings update
      final endpoint = 'user/$userId/subuser/$subUserId/controller/$controllerId/menu/92/settings';

      Map<String, dynamic> templateJson = {};
      try {
        if (entity.templateJson.startsWith('{')) {
          templateJson = jsonDecode(entity.templateJson).cast<String, dynamic>();
        } else {
          templateJson = {"FLOWPERCENT": entity.flowDeviation, "type": "52"};
        }
      } catch (_) {
        templateJson = {"FLOWPERCENT": entity.flowDeviation, "type": "52"};
      }

      templateJson['FLOWPERCENT'] = entity.flowDeviation;

      // Single POST request body as per senior's logic
      // Backend uses 'sentSms' field to create the single unified history log entry.
      final body = {
        "menuSettingId": 488,
        "receivedData": "",
        "sentSms": sentSms, // Single unified string (e.g. FLOWVALSET,001,22)
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

      // 1. Save data to database (this handles the status log on the backend)
      await remoteSource.saveValveFlowSettings(endpoint: endpoint, body: body);

      // 2. Publish Hardware Command via MQTT for real-time sync
      await remoteSource.publishMqttCommand(
        controllerId: controllerId,
        command: jsonEncode({"sentSms": sentSms}),
      );

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
