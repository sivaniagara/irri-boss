import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/edit_zone/domain/repositories/zone_configuration_repository.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/edit_zone/domain/usecases/get_zone_configuration_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/program_settings/sub_module/edit_zone/domain/usecases/submit_zone_configuration_usecase.dart';
import '../../../../../../core/error/success.dart';
import '../../domain/entities/zone_nodes_entity.dart';
import '../../domain/usecases/edit_zone_configuration_usecase.dart';
import '../../domain/usecases/submit_while_edit_zone_configuration.dart';
import '../data_source/zone_configuration_remote_source.dart';
import '../models/zone_configuration_model.dart';

class ZoneConfigurationRepositoryImpl implements ZoneConfigurationRepository{
  final ZoneConfigurationRemoteSource zoneConfigurationRemoteSource;
  ZoneConfigurationRepositoryImpl({required this.zoneConfigurationRemoteSource});

  @override
  Future<Either<Failure, ZoneConfigurationEntity>>
  getZoneConfiguration(GetZoneConfigurationParams params) async {
    if(kDebugMode){
      print('ZoneConfigurationRepositoryImpl --> getZoneConfiguration --> ** initialize  **');
    }
    try {
      final response =
      await zoneConfigurationRemoteSource.getZoneConfiguration({
        'userId': params.userId,
        'controllerId': params.controllerId,
        'programId': params.programId,
      });

      final model =
      ZoneConfigurationModel.fromJson(response['data']);

      return Right(model);
    } catch (e, stackTrace) {
      if(kDebugMode){
        print('getZoneConfiguration :: $e');
        print('stackTrace :: $stackTrace');
      }
      return Left(
        ServerFailure('getZoneConfiguration failed: $e'),
      );
    }
  }


  @override
  Future<Either<Failure, Unit>> submitZoneConfiguration(SubmitZoneConfigurationParams params) async{
    try{
      ZoneConfigurationModel zoneConfigurationModel = ZoneConfigurationModel.fromEntity(params.zoneNodes);
      Map<String, dynamic> body = zoneConfigurationModel.submitZone(programId: params.programId, whileEdit: true);
      Map<String, String> urlData = {
        'userId': params.userId,
        'controllerId': params.controllerId,
        'programId': params.programId,
      };
      final response = await zoneConfigurationRemoteSource.submitZoneConfiguration(urlData: urlData, body: body);
      if(response['code'] == 200){
        return Right(unit);
      }else{
        return Left(ServerFailure(response['message']));
      }
    }catch(e, stackTrace){
      print(e.toString());
      print(stackTrace);
      return Left(ServerFailure('submitZoneConfiguration failed: $e'));
    }

  }

  @override
  Future<Either<Failure, Unit>> submitWhileEditZoneConfiguration(SubmitWhileEditZoneConfigurationParams params) async{
    try{
      ZoneConfigurationModel zoneConfigurationModel = ZoneConfigurationModel.fromEntity(params.zoneNodes);
      Map<String, dynamic> body = zoneConfigurationModel.submitZone(programId: params.programId);
      Map<String, String> urlData = {
        'userId': params.userId,
        'controllerId': params.controllerId,
        'programId': params.programId,
      };
      final response = await zoneConfigurationRemoteSource.submitWhenEditZoneConfiguration(urlData: urlData, body: body);
      if(response['code'] == 200){
        return Right(unit);
      }else{
        return Left(ServerFailure(response['message']));
      }
    }catch(e, stackTrace){
      print(e.toString());
      print(stackTrace);
      return Left(ServerFailure('submitZoneConfiguration failed: $e'));
    }

  }


  @override
  Future<Either<Failure, ZoneConfigurationEntity>>
  editZoneConfiguration(EditZoneConfigurationParams params) async {
    if(kDebugMode){
      print('ZoneConfigurationRepositoryImpl --> editZoneConfiguration --> ** initialize  **');
    }
    try {
      final response =
      await zoneConfigurationRemoteSource.editZoneConfiguration({
        'userId': params.userId,
        'controllerId': params.controllerId,
        'programId': params.programId,
        'zoneSerialNo': params.zoneSerialNo,
      });

      final model =
      ZoneConfigurationModel.fromJsonWhileEdit(response['data'], 'ZONE${params.zoneSerialNo}');

      return Right(model);
    } catch (e, stackTrace) {
      if(kDebugMode){
        print('editZoneConfiguration :: $e');
        print('stackTrace :: $stackTrace');
      }
      return Left(
        ServerFailure('editZoneConfiguration failed: $e'),
      );
    }
  }
}