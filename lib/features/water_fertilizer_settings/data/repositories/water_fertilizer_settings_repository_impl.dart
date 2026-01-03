import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/domain/entities/program_zone_set_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/domain/repositories/water_fertilizer_settings_repository.dart';
import 'package:niagara_smart_drip_irrigation/features/water_fertilizer_settings/domain/usecases/fetch_program_zone_sets_usecase.dart';

import '../../domain/usecases/fetch_zone_set_setting_usecase.dart';
import '../../domain/usecases/update_zone_set_setting_usecase.dart';
import '../data_source/water_fertilizer_settings_remote_source.dart';
import '../models/program_zone_set_model.dart';

class WaterFertilizerSettingsRepositoryImpl extends WaterFertilizerSettingsRepository{
  final WaterFertilizerSettingsRemoteSource remoteSource;
  WaterFertilizerSettingsRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<Failure, ProgramZoneSetEntity>> fetchProgramZoneSets(FetchProgramZoneSetsParams params) async{
    try{
      final response = await remoteSource.fetchProgramZoneSets(
          urlData: {
            'userId' : params.userId,
            'controllerId' : params.controllerId,
            'subUserId' : params.subUserId,
            'programId' : params.programId,
          });
      if(response['data'].isNotEmpty){
        ProgramZoneSetModel programZoneSetModel = ProgramZoneSetModel.fromJson(
          programId: params.programId,
            programData: response['data'][0],
            listOfZoneSet: response['data'].sublist(1, response['data'].length)
        );
        return Right(programZoneSetModel);
      }else{
        return Left(ServerFailure('Zone not available!'));
      }

    }catch(e, stackTrace){
      if (kDebugMode) {
        print(stackTrace);
      }
      print(e);
      return Left(ServerFailure('Fetch zone set failed :: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ProgramZoneSetEntity>> fetchZoneSetSettings(FetchZoneSetSettingParams params) async{
    try{
      final response = await remoteSource.fetchZoneSetSettings(
          urlData: {
            'userId' : params.userId,
            'controllerId' : params.controllerId,
            'subUserId' : params.subUserId,
            'programSettingNo' : params.programSettingNo,
            'zoneSetId' : params.zoneSetId,
          });
      if(response['data'].isNotEmpty && response['data'][0]['sendData'].toString().isNotEmpty){
        var senData = jsonDecode(response['data'][0]['sendData']);
        ProgramZoneSetModel programZoneSetModel = ProgramZoneSetModel.fromJson(
          programId: params.programId,
            programData: senData[0],
            listOfZoneSet: senData.sublist(1, senData.length)
        );
        return Right(programZoneSetModel);
      }else{
        return Left(ServerFailure('Zone set setting not available!'));
      }

    }catch(e, stackTrace){
      if (kDebugMode) {
        print(stackTrace);
      }
      print(e);
      return Left(ServerFailure('Fetch zone set failed :: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateZoneSetSettings(UpdateZoneSetSettingParams params) async{
    try{
      ProgramZoneSetModel programZoneSetModel = ProgramZoneSetModel.fromEntity(entity: params.programZoneSetEntity);
      final response = await remoteSource.updateZoneSetSettings(
            urlData: {
              'userId' : params.userId,
              'controllerId' : params.controllerId,
              'subUserId' : params.subUserId,
              'programSettingNo' : params.programSettingNo,
              'zoneSetId' : params.zoneSetId,
            },
        bodyData: programZoneSetModel.httpPayload(
            programSettingNo: params.programSettingNo,
            channelNo: params.channelNo,
            irrigationDosingOrPrePost: params.irrigationDosingOrPrePost,
            mode: params.mode, method: params.method, zoneSetId: params.zoneSetId
        )
          );
      if(response['code'] == 200){
        return Right(unit);
      }else{
        return Left(ServerFailure('Zone set setting not updated!'));
      }

    }catch(e, stackTrace){
      if (kDebugMode) {
        print(stackTrace);
      }
      print(e);
      return Left(ServerFailure('Fetch zone set failed :: ${e.toString()}'));
    }
  }
}