import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';

import '../entities/mapping_and_unmapping_node_entity.dart';
import '../usecases/delete_mapped_node_usecase.dart';
import '../usecases/fetch_mapping_unmapping_nodes_usecase.dart';
import '../usecases/unmapped_node_to_mapped_node_usecase.dart';

abstract class MappingAndUnmappingNodesRepository{
  Future<Either<Failure, MappingAndUnmappingNodeEntity>> fetchMappingAndUnmappingNode(FetchMappingUnmappingParams params);
  Future<Either<Failure, Unit>> deleteMappedNode(DeleteMappedNodeParams params);
  Future<Either<Failure, Unit>> unmappedNodeToMapped(UnmappedNodeToMappedNodeParams params);
}