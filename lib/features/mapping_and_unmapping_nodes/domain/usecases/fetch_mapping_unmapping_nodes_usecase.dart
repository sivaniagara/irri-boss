import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../entities/mapping_and_unmapping_node_entity.dart';
import '../repositories/mapping_and_unmapping_nodes_repository.dart';

class FetchMappingUnmappingParams{
  final String userId;
  final String controllerId;
  FetchMappingUnmappingParams({required this.userId, required this.controllerId,});
}


class FetchMappingUnmappingNodesUsecase extends UseCase<MappingAndUnmappingNodeEntity, FetchMappingUnmappingParams>{
  final MappingAndUnmappingNodesRepository repository;
  FetchMappingUnmappingNodesUsecase({required this.repository});

  @override
  Future<Either<Failure, MappingAndUnmappingNodeEntity>> call(FetchMappingUnmappingParams params)async{
    return repository.fetchMappingAndUnmappingNode(params);
  }

}