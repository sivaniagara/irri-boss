import 'dart:convert';

import 'package:dartz/dartz.dart';

import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/data/models/controller_irrigation_setting_model.dart';

import 'package:niagara_smart_drip_irrigation/features/irrigation_settings/domain/entities/controller_irrigation_setting_entity.dart';

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

}