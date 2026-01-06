import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/data/models/controller_irrigation_setting_model.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/data/models/valve_flow_model.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/controller_irrigation_setting_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/valve_flow_entity.dart';
import '../../domain/repositories/irrigation_settings_repository.dart';
import '../../domain/usecases/get_template_irrigation_setting_usecase.dart';
import '../data_source/irrigation_settings_remote_source.dart';

class IrrigationSettingsRepositoryImpl extends IrrigationSettingsRepository{
  final IrrigationSettingsRemoteSource dataSource;

  IrrigationSettingsRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, ControllerIrrigationSettingEntity>> getTemplateSetting(GetTemplateIrrigationSettingParams params) async{
    try{
      final response = await dataSource.getTemplateSetting(urlData: {
        'userId' : params.userId,
        'controllerId' : params.controllerId,
        'subUserId' : params.subUserId,
        'settingId' : params.settingNo,
      });
      if(response['code'] == 200){
        Map<String, dynamic> jsonData = jsonDecode(response["data"][0]['sendData']);
        ControllerIrrigationSettingModel controllerIrrigationSettingModel =
        ControllerIrrigationSettingModel.fromJson(json: jsonData);
        return Right(controllerIrrigationSettingModel);
      }else{
        return Left(ServerFailure(response['message'] ?? 'Unknown error'));
      }
    }catch(e){
      return Left(ServerFailure('getTemplateSetting failed: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ValveFlowEntity>> getValveFlowSetting(GetTemplateIrrigationSettingParams params) async {
    try {
      final nodeResponse = await dataSource.getNodeList(urlData: {
        'userId': params.userId,
        'controllerId': params.controllerId,
        'subUserId': params.subUserId,
      });

      final settingResponse = await dataSource.getValveFlowSetting(urlData: {
        'userId': params.userId,
        'controllerId': params.controllerId,
        'subUserId': params.subUserId,
      });

      if (settingResponse['code'] == 200 && nodeResponse['code'] == 200) {
        final valveFlowModel = ValveFlowModel.fromJson(settingResponse['data'][0]);
        final nodeList = nodeResponse['data'] as List;

        final updatedNodes = valveFlowModel.nodes.map((valveNode) {
          final matchingNode = nodeList.firstWhere(
            (n) => n['nodeId'].toString() == valveNode.nodeId,
            orElse: () => null,
          );
          if (matchingNode != null && valveNode.nodeName.isEmpty) {
            return valveNode.copyWith(nodeName: matchingNode['nodeName']);
          }
          return valveNode;
        }).toList();

        return Right(valveFlowModel.copyWith(nodes: updatedNodes));
      } else {
        return Left(ServerFailure(settingResponse['message'] ?? nodeResponse['message'] ?? 'Fetch failed'));
      }
    } catch (e) {
      return Left(ServerFailure('getValveFlowSetting failed: ${e.toString()}'));
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
      // 1. MQTT Hardware Command
      print("sent sms:  $sentSms");
      await dataSource.publishMqttCommand(
        controllerId: controllerId,
        command: jsonEncode({"sentSms": sentSms}), 
      );
      // 2. Status History Log - Single unified string line
      await dataSource.logHistory(
        userId: userId,
        subUserId: int.tryParse(subUserId) ?? 0,
        controllerId: controllerId,
        sentSms: sentSms, 
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('publishValveFlowSms failed: ${e.toString()}'));
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
      // Use the generic newSettings POST endpoint to resolve 404 and match legacy patterns

      final endpoint = 'user/$userId/subuser/$subUserId/controller/$controllerId/menu/92/newSettings';
      
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
        "sentSms": "", // Handled separately by logHistory call in BLoC to avoid double logging
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

      await dataSource.saveValveFlowSettings(endpoint: endpoint, body: body, method: 'POST');
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('saveValveFlowSettings: ${e.toString()}'));
    }
  }
}