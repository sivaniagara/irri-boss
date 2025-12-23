import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';

import '../entities/mapping_and_unmapping_node_entity.dart';
import '../usecases/fetch_mapping_unmapping_nodes_usecase.dart';

abstract class MappingAndUnmappingNodesRepository{
  Future<Either<Failure, MappingAndUnmappingNodeEntity>> fetchMappingAndUnmappingNode(FetchMappingUnmappingParams params);
}