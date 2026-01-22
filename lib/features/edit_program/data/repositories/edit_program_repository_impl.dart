import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';

import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/entities/edit_program_entity.dart';

import 'package:niagara_smart_drip_irrigation/features/edit_program/domain/usecases/get_program_usecase.dart';

import '../../domain/repositories/edit_program_repository.dart';
import '../../domain/usecases/send_zone_configuration_payload_usecase.dart';
import '../../domain/usecases/send_zone_set_payload_usecase.dart';
import '../data_source/edit_program_remote_source.dart';
import '../models/edit_program_model.dart';
import '../models/zone_setting_model.dart';

class GetProgramRepositoryImpl extends EditProgramRepository{
  final EditProgramRemoteSource remoteSource;
  GetProgramRepositoryImpl({required this.remoteSource});

  @override
  Future<Either<Failure, EditProgramEntity>> getProgram(GetProgramParams params) async{
    try {
      final response = await remoteSource.getPrograms(
          urlData: {
            'userId' : params.userId,
            'controllerId' : params.controllerId,
            'subUserId' : params.subUserId,
            'programId' : params.programId.toString()
          });
      // var response = {
      //   "code": 200,
      //   "message": "Node successfully listed",
      //   "default" : {
      //     "valves" : [
      //       {
      //         "QRCode": "151091229001",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5042,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "001",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229002",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5041,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "002",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229003",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5040,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "003",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229004",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5039,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "004",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229005",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5038,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "005",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229006",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5037,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "006",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229007",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5036,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "007",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229008",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5035,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "008",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094001",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4993,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "009",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094002",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4992,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "010",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094003",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4991,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "011",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094004",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4990,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "012",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094005",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4989,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "013",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       }
      //     ],
      //     "moistureSensors" : [
      //       {
      //         "QRCode": "151091229001",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5042,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "001",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229002",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5041,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "002",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229003",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5040,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "003",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229004",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5039,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "004",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229005",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5038,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "005",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229006",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5037,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "006",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229007",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5036,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "007",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229008",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5035,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "008",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094001",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4993,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "009",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094002",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4992,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "010",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094003",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4991,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "011",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094004",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4990,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "012",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094005",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4989,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "013",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       }
      //     ],
      //     "levelSensors" : [
      //       {
      //         "QRCode": "151091229001",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5042,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "001",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229002",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5041,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "002",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229003",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5040,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "003",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229004",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5039,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "004",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229005",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5038,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "005",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229006",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5037,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "006",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229007",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5036,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "007",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "151091229008",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 5035,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "008",
      //         "categoryId": 2,
      //         "dateManufacture": "20/09/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094001",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4993,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "009",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094002",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4992,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "010",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094003",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4991,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "011",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094004",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4990,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "012",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       },
      //       {
      //         "QRCode": "224097094005",
      //         "nodeName": "",
      //         "categoryName": "Valves",
      //         "nodeId": 4989,
      //         "userName": "Niagara Solutions",
      //         "serialNo": "013",
      //         "categoryId": 2,
      //         "dateManufacture": "25/10/2021",
      //         "modelName": "Valve Controller"
      //       }
      //     ],
      //   },
      //   "data" : {
      //     "programId": 1,
      //     "programName": "Program 1",
      //     "timerAdjustPercent": 80.0,
      //     "flowAdjustPercent": 80.0,
      //     "moistureAdjustPercent": 80.0,
      //     "fertilizerAdjustPercent": 80.0,
      //     "zones": [
      //     ]
      //   },
      // };
      // await Future.delayed(Duration(seconds: 1));
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
  Future<Either<Failure, Unit>> sendZoneSetPayload(
      SendZoneSetPayloadParams params) async{
    try {
      int start(int zoneSetNo){
        if(zoneSetNo == 1) return 0;
        return (zoneSetNo * 8) - 9;
      }
      int end(int zoneSetNo, int zoneLength){
        if((zoneSetNo * 8) < zoneLength) return zoneSetNo * 8;
        return zoneLength;
      }
        EditProgramModel editProgramModel = EditProgramModel.fromEntity(params.editProgramEntity);
      print(start(params.zoneSetNo));
      print(end(params.zoneSetNo, params.editProgramEntity.zones.length));
        List<ZoneSettingModel> zoneSet = params.editProgramEntity.zones.sublist(
            start(params.zoneSetNo),
            end(params.zoneSetNo, params.editProgramEntity.zones.length)
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
}