import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/data/models/mapping_and_unmapping_node_model.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/entities/mapping_and_unmapping_node_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/repositories/mapping_and_unmapping_nodes_repository.dart';
import 'package:niagara_smart_drip_irrigation/features/mapping_and_unmapping_nodes/domain/usecases/fetch_mapping_unmapping_nodes_usecase.dart';

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
}