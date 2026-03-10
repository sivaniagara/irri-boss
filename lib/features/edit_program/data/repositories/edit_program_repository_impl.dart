import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';

import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/entities/edit_program_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/usecases/delete_zone_usecase.dart';

import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/usecases/get_program_usecase.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/services/mqtt/publish_messages.dart';
import '../../domain/repositories/edit_program_repository.dart';
import '../../domain/usecases/save_program_usecase.dart';
import '../../domain/usecases/send_view_message_usecase.dart';
import '../../domain/usecases/send_zone_configuration_payload_usecase.dart';
import '../../domain/usecases/send_zone_set_payload_usecase.dart';
import '../../domain/usecases/send_zone_view_command_usecase.dart';
import '../data_source/edit_program_remote_source.dart';
import '../models/edit_program_model.dart';
import '../models/zone_setting_model.dart';

class GetProgramRepositoryImpl extends EditProgramRepository{
  final EditProgramRemoteSource remoteSource;
  GetProgramRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<Failure, EditProgramEntity>> getProgram(GetProgramParams params) async{
    try {
      final response = await remoteSource.getProgram(
          urlData: {
            'userId' : params.userId,
            'controllerId' : params.controllerId,
            'subUserId' : params.subUserId,
            'programId' : params.programId.toString()
          });
      return Right(
          EditProgramModel.fromJson(response)
      );
    } catch (e, stackTrace) {
      print('getPrograms Fetching Failure: $e');
      print(stackTrace);
      return Left(ServerFailure('getPrograms Fetching Failure: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveProgram(SaveProgramParams params) async{
    try {
      EditProgramModel editProgramModel = EditProgramModel.fromEntity(params.editProgramEntity);
      final response = await remoteSource.saveProgram(
          urlData: {
            'userId' : params.userId,
            'controllerId' : params.controllerId,
            'programId' : params.editProgramEntity.programId.toString()
          },
          bodyData: {
            "setting" : editProgramModel.toJson()
          }
      );
      if(response['code'] == 200){
        return Right(
            unit
        );
      }else{
        return Left(ServerFailure('saveProgram Fetching Failure: ${response['message']}'));
      }

    } catch (e, stackTrace) {
      print('saveProgram Fetching Failure: $e');
      print(stackTrace);
      return Left(ServerFailure('saveProgram Fetching Failure: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendZoneConfigurationPayload(
      SendZoneConfigurationParams params) async{
    try {
      ZoneSettingModel zoneSettingModel = ZoneSettingModel.fromEntity(params.zoneSettingEntity);
      final response = await remoteSource.sendZonePayload(
          urlData: {'userId' : params.userId, 'controllerId' : params.controllerId},
          bodyData: {},
          listOfPayload: zoneSettingModel.submitZone(programId: params.programId),
          deviceId: params.deviceId
      );
      await Future.delayed(Duration(seconds: 2));
      return Right(unit);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('sendZoneConfigurationPayload Failure: $e');
        print(stackTrace);
      }
      return Left(ServerFailure('sendZoneConfigurationPayload Fetching Failure: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendZoneViewCommandPayload(
      SendZoneViewCommandParams params) async{
    try {
      final response = await remoteSource.sendZonePayload(
          urlData: {'userId' : params.userId, 'controllerId' : params.controllerId},
          bodyData: {},
          listOfPayload: [
            PublishMessageHelper.settingsPayload('VIDZONESELP${params.programId}${params.zoneNo.padLeft(3, '0')}'),
            PublishMessageHelper.settingsPayload('VIDZLMSETP${params.programId}${params.zoneNo.padLeft(3, '0')}'),
          ],
          deviceId: params.deviceId
      );
      await Future.delayed(Duration(seconds: 2));
      return Right(unit);
    } catch (e, stackTrace) {

      if (kDebugMode) {
        print('sendZoneViewCommandPayload Failure: $e');
        print(stackTrace);
      }
      return Left(ServerFailure('sendZoneViewCommandPayload Fetching Failure: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteZone(DeleteZoneParamsEditProgram params) async{
    try {
      final response = await remoteSource.deleteZone({'userId' : params.userId, 'controllerId' : params.controllerId, 'programId' : params.programId, 'zoneSerialNo' : params.zoneSerialNo});
      if(response['code'] == 200){
        return Right(unit);
      }else{
        return Left(ServerFailure(response['message']));
      }
    } catch (e) {
      return Left(ServerFailure('getPrograms Fetching Failure: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendZoneSetPayload(
      SendZoneSetPayloadParams params) async{
    try {
      final takingActiveZoneByZoneSet = [];
      for(var i = 0; i < params.editProgramEntity.zones.length;i++){
        if(params.editProgramEntity.zones[i].active){
          takingActiveZoneByZoneSet.add(params.editProgramEntity.zones[i]);
        }
      }
      int start(int zoneSetNo){
        if(zoneSetNo == 1) return 0;
        return (zoneSetNo * 8) - 9;
      }
      int end(int zoneSetNo, int zoneLength){
        if((zoneSetNo * 8) < zoneLength) return zoneSetNo * 8;
        return zoneLength;
      }
        EditProgramModel editProgramModel = EditProgramModel.fromEntity(params.editProgramEntity);
      print("takingActiveZoneByZoneSet : ${takingActiveZoneByZoneSet}");
      print(start(params.zoneSetNo));
      print(end(params.zoneSetNo, params.editProgramEntity.zones.length));
        List<ZoneSettingModel> zoneSet = takingActiveZoneByZoneSet.sublist(
            start(params.zoneSetNo),
            end(params.zoneSetNo, params.editProgramEntity.zones.length).clamp(0, takingActiveZoneByZoneSet.length)

    ).map((e) => ZoneSettingModel.fromEntity(e)).toList();
      final response = await remoteSource.sendZonePayload(
          urlData: {'userId' : params.userId, 'controllerId' : params.controllerId},
          bodyData: {},
          listOfPayload: [
            editProgramModel.mqttPayload(
                channelNo: params.channelNo,
                irrigationDosingOrPrePost: params.irrigationDosingOrPrePost,
                method: params.method,
                mode: params.irrigationDosingOrPrePost == 1 ? 1 : 2,
                zoneSetId: params.zoneSetNo.toString(),
                listOfZone: zoneSet
            ),
            editProgramModel.mqttPayload(
                channelNo: params.channelNo,
                irrigationDosingOrPrePost: params.irrigationDosingOrPrePost,
                method: params.method,
                mode: params.irrigationDosingOrPrePost == 1 ? 3 : 4,
                zoneSetId: params.zoneSetNo.toString(),
                listOfZone: zoneSet
            ),

          ],
          deviceId: params.deviceId
      );
      await Future.delayed(Duration(seconds: 2));
      return Right(unit);
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('sendZoneConfigurationPayload Failure: $e');
        print(stackTrace);
      }
      return Left(ServerFailure('sendZoneConfigurationPayload Fetching Failure: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendViewMessage(SendViewMessageParam params) async {
    try {
      final response = await remoteSource.sendViewMessage(
        userId: params.userId,
        controllerId: params.controllerId,
        programId: params.programId,
        deviceId: params.deviceId,
        payload: params.payload,
      );
      if(response){
        return Right(unit);
      }else{
        return Left(ServerFailure('sendViewMessage Payload not sent'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch controllers: $e'));
    }
  }
}