import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/data/models/mapped_node_model.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/data/models/mapping_and_unmapping_node_model.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/data/models/unmapped_category_node_model.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/mapping_and_unmapping_node_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/repositories/mapping_and_unmapping_nodes_repository.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/usecases/delete_mapped_node_usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/usecases/fetch_mapping_unmapping_nodes_usecase.dart';

import '../../domain/usecases/resend_mapped_node_usecase.dart';
import '../../domain/usecases/unmapped_node_to_mapped_node_usecase.dart';
import '../../domain/usecases/view_node_details_mqtt_usecase.dart';
import '../data_source/mapping_and_unmapping_nodes_remote_source.dart';

class MappingAndUnmappingNodesRepositoryImpl extends MappingAndUnmappingNodesRepository{
  final MappingAndUnmappingNodesRemoteSource mappingAndUnmappingNodesRemoteSource;
  MappingAndUnmappingNodesRepositoryImpl({required this.mappingAndUnmappingNodesRemoteSource});

  @override
  Future<Either<Failure, MappingAndUnmappingNodeEntity>> fetchMappingAndUnmappingNode(FetchMappingUnmappingParams params) async{
    try{
      final response = await mappingAndUnmappingNodesRemoteSource.fetchMappingUnMappingNodeData(urlData: {'userId' : params.userId, 'controllerId' : params.controllerId});
      MappingAndUnmappingNodeModel mappingAndUnmappingNodeModel = MappingAndUnmappingNodeModel.fromJson(response['data']);
      return Right(mappingAndUnmappingNodeModel);
    }catch(e, stackTrace){
      if (kDebugMode) {
        print(stackTrace);
      }
      print(e);
      return Left(ServerFailure('Fetch Mapping and Unmapping Node failed :: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMappedNode(DeleteMappedNodeParams params) async{
    try{
      MappedNodeModel mappedNodeModel = MappedNodeModel.fromEntity(params.mappedNodeEntity);
      final response = await mappingAndUnmappingNodesRemoteSource
          .deleteMappedNode(
          urlData: {
            'userId' : params.userId,
            'controllerId' : params.controllerId,
            'nodeId' : mappedNodeModel.nodeId.toString(),
            'payload' : mappedNodeModel.deleteMappedNodePayload()
          },
          deviceId: params.deviceId
      );
      if(response['code'] == 200){
        return Right(unit);
      }else{
        return Left(ServerFailure(response['message']));
      }
    }catch(e, stackTrace){
      if (kDebugMode) {
        print(stackTrace);
        print(e);
      }
      return Left(ServerFailure('Delete Mapped Node Failed :: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> unmappedNodeToMapped(UnmappedNodeToMappedNodeParams params) async{
    try{
      List<int> listOfMappedSerialNo = params.listOfMappedNodeEntity.map((e) => int.parse(e.serialNo)).toList();
      List<UnmappedCategoryNodeModel> unmappedCategoryNodeModel = params.listOfUnmappedCategoryNodeEntity.map(((e){
        return UnmappedCategoryNodeModel.fromEntity(e);
      })).toList();
      print("listOfMappedSerialNo :: $listOfMappedSerialNo");
      final response = await mappingAndUnmappingNodesRemoteSource
          .unmappedToMapped(
          urlData: {
            'userId' : params.userId,
            'controllerId' : params.controllerId,
          },
          deviceId: params.deviceId,
          bodyData: {
            'nodeList' : List.generate(unmappedCategoryNodeModel.length, (index){
              int? serialNo;
              for(var i = 1;i < 100;i++){
                if(!listOfMappedSerialNo.contains(i)){
                  serialNo = i;
                  listOfMappedSerialNo.add(i);
                }
                if(serialNo != null){
                  break;
                }
              }
              print(serialNo.toString().padLeft(3, '0'));
              return unmappedCategoryNodeModel[index].formPayload(
                  params.categoryId,
                  serialNo.toString().padLeft(3, '0')
              );
            })
          }
      );
      if(response['code'] == 200){
        return Right(unit);
      }else{
        return Left(ServerFailure(response['message']));
      }
    }catch(e, stackTrace){
      if (kDebugMode) {
        print(stackTrace);
        print(e);
      }
      return Left(ServerFailure('Delete Mapped Node Failed :: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> viewNodeDetailsMqtt(ViewNodeDetailsMqttParams params) async {
    try {
      String payload = "VIDSET${params.mappedNodeEntity.serialNo}";
      final result = await mappingAndUnmappingNodesRemoteSource.sendMessageViaMqtt(
        deviceId: params.deviceId,
        payload: payload,
        userId: params.userId,
        controllerId: params.controllerId,
        programId: '0',
      );
      if(result){
        return const Right(unit);
      }else{
        return Left(ServerFailure('View Node Details Failed'));
      }
    } catch (e) {
      return Left(ServerFailure('Send Node Details via MQTT Failed :: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> resendMappedNode(ResendMappedNodeParams params) async {
    try {
      String splitQrCode(String qrCode){
        int chunkSize = 3;
        List<String> splitList = [
          for (int i = 0; i < qrCode.length; i += chunkSize)
            qrCode.substring(i, i + chunkSize > qrCode.length ? qrCode.length : i + chunkSize)
        ];
        return splitList.join(',');
      }
      String payload = "IDSET${params.mappedNodeEntity.serialNo},${splitQrCode(params.mappedNodeEntity.qrCode)}";
      final result = await mappingAndUnmappingNodesRemoteSource.sendMessageViaMqtt(
        deviceId: params.deviceId,
        payload: payload,
        userId: params.userId,
        controllerId: params.controllerId,
        programId: '0',
      );
      if(result){
        return const Right(unit);
      }else{
        return Left(ServerFailure('Resend Mapped Node Failed'));
      }
    } catch (e) {
      return Left(ServerFailure('Resend Node Details via MQTT Failed :: ${e.toString()}'));
    }
  }
}