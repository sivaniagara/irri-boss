import 'dart:convert';

import 'package:dartz/dartz.dart';

import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/data/models/controller_irrigation_setting_model.dart';

import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/controller_irrigation_setting_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/usecases/update_template_irrigation_setting_usecase.dart';

import '../../../../core/services/mqtt/publish_messages.dart';
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
        return Left(ServerFailure(response['message']));
      }

    }catch(e, stackTrace){
      print(stackTrace);
      print('getTemplateSetting => ${e.toString()}');
      return Left(ServerFailure('getTemplateSetting failed : ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTemplateSetting(UpdateTemplateIrrigationSettingParams params) async{
    try{
      ControllerIrrigationSettingModel controllerIrrigationSettingModel =
      ControllerIrrigationSettingModel.fromEntity(entity: params.controllerIrrigationSettingEntity);
      var jsonData = controllerIrrigationSettingModel.toJson();
      var mqttData = controllerIrrigationSettingModel.getMqttPayload(groupIndex: params.groupIndex, settingIndex: params.settingIndex);
      print("mqttData : $mqttData");
      final response = await dataSource.updateTemplateSetting(
          urlData: {
            'userId' : params.userId,
            'controllerId' : params.controllerId,
            'subUserId' : params.subUserId,
          },
          body: {
            "sendData": jsonEncode(jsonData),
            "receivedData": "",
            "menuSettingId": params.settingNo,
            "sentSms": mqttData
          },
          deviceId: params.deviceId
      );
      if(response['code'] == 200){
        return Right(unit);
      }else{
        return Left(ServerFailure(response['message']));
      }
    }catch(e, stackTrace){
      print(stackTrace);
      print('updateTemplateSetting => ${e.toString()}');
      return Left(ServerFailure('updateTemplateSetting failed : ${e.toString()}'));
    }
  }

}