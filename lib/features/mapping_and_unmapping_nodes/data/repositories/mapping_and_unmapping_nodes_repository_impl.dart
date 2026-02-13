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
      List<UnmappedCategoryNodeModel> unmappedCategoryNodeModel = params.listOfUnmappedCategoryNodeEntity.map(((e){
        return UnmappedCategoryNodeModel.fromEntity(e);
      })).toList();
      final response = await mappingAndUnmappingNodesRemoteSource
          .unmappedToMapped(
          urlData: {
            'userId' : params.userId,
            'controllerId' : params.controllerId,
          },
          deviceId: params.deviceId,
          bodyData: {
            'nodeList' : List.generate(unmappedCategoryNodeModel.length, (index){
              return unmappedCategoryNodeModel[index].formPayload(
                  params.categoryId,
                  (params.mappedNodeLength + index + 1).toString().padLeft(3, '0')
              );
            })
            // 'nodeList' : unmappedCategoryNodeModel.map((e) => e.formPayload(params.categoryId)).toList()
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
      // Assuming a payload format for viewing details, or just notifying the node.
      // Based on deleteMappedNodePayload, it might be something similar.
      // For now, I'll use a placeholder or the serial number if no specific format is known.
      String payload = "VDSET${params.mappedNodeEntity.serialNo}";
      mappingAndUnmappingNodesRemoteSource.viewNodeDetailsMqtt(
        deviceId: params.deviceId,
        payload: payload,
      );
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Send Node Details via MQTT Failed :: ${e.toString()}'));
    }
  }
}