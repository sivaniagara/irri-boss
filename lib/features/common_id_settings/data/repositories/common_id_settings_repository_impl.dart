import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/data/models/category_model.dart';

import 'package:niagara_smart_drip_irrigation/features/common_id_settings/domain/entities/category_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/common_id_settings/domain/usecases/submit_category_usecase.dart';

import '../../domain/repositories/common_id_settings_repository.dart';
import '../../domain/usecases/get_common_id_settings_usecase.dart';
import '../../domain/usecases/reset_common_id_usecase.dart';
import '../../domain/usecases/view_common_id_usecase.dart';
import '../data_source/common_id_settings_remote_source.dart';

class CommonIdSettingsRepositoryImpl implements CommonIdSettingsRepository{
  final CommonIdSettingsRemoteSource commonIdSettingsDataSource;
  CommonIdSettingsRepositoryImpl({required this.commonIdSettingsDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCommonIdSettings(GetCommonIdSettingsParams params) async{
    if(kDebugMode){
      print('CommonIdSettingsRepositoryImpl --> getCommonIdSettings --> ** initialize  **');
    }
    try {
      final response =
          await commonIdSettingsDataSource.getCommonIdSettings({
        'userId': params.userId,
        'controllerId': params.controllerId,
        'subUserId': '0',
      });
      List<CategoryModel> listOfCategoryModel = response['data'].map<CategoryModel>((e) => CategoryModel.fromJson(e)).toList();

      return Right(listOfCategoryModel);
    } catch (e, stackTrace) {
      if(kDebugMode){
        print('getCommonIdSettings :: $e');
        print('stackTrace :: $stackTrace');
      }
      return Left(
        ServerFailure('getCommonIdSettings failed: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateCategoryNodeSerialNo(SubmitCategoryParams params) async{
    if(kDebugMode){
      print('CommonIdSettingsRepositoryImpl --> updateCategoryNodeSerialNo --> ** initialize  **');
    }
    try {
      var urlData = {
        'userId': params.userId,
        'controllerId': params.controllerId,
        'subUserId': '0',
      };

      CategoryModel categoryModel = CategoryModel.fromEntity(params.categoryEntity);
      var bodyData = categoryModel.updateCategoryNodeSerialNoPayload();
      print('bodyData : $bodyData');
      final response =
          await commonIdSettingsDataSource.updateCategoryNodeSerialNo(
              urlData: urlData,
              body: bodyData
          );
      if(response['code'] == 200){
        return Right(unit);
      }else{
        return Left(response['message']);
      }

    } catch (e, stackTrace) {
      if(kDebugMode){
        print('updateCategoryNodeSerialNo :: $e');
        print('stackTrace :: $stackTrace');
      }
      return Left(
        ServerFailure('updateCategoryNodeSerialNo failed: $e'),
      );
    }
  }


  @override
  Future<Either<Failure, Unit>> resetCommonId(ResetCommonIdParams params) async{
    try {
      CategoryModel categoryModel = CategoryModel.fromEntity(params.categoryEntity);
      String payload = categoryModel.resetPayload();
      final result = await commonIdSettingsDataSource.sendMessageViaMqtt(
        deviceId: params.deviceId,
        payload: payload,
        userId: params.userId,
        controllerId: params.controllerId,
        programId: '0',
      );
      if(result){
        return const Right(unit);
      }else{
        return Left(ServerFailure('Reset Command Failed'));
      }
    } catch (e) {
      return Left(ServerFailure('Reset Command via MQTT Failed :: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> viewCommonId(ViewCommonIdParams params) async{
    try {
      CategoryModel categoryModel = CategoryModel.fromEntity(params.categoryEntity);
      String payload = categoryModel.viewPayload();      final result = await commonIdSettingsDataSource.sendMessageViaMqtt(
        deviceId: params.deviceId,
        payload: payload,
        userId: params.userId,
        controllerId: params.controllerId,
        programId: '0',
      );
      if(result){
        return const Right(unit);
      }else{
        return Left(ServerFailure('Reset Command Failed'));
      }
    } catch (e) {
      return Left(ServerFailure('Reset Command via MQTT Failed :: ${e.toString()}'));
    }
  }

}