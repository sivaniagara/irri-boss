import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../entities/unmapped_category_node_entity.dart';
import '../repositories/mapping_and_unmapping_nodes_repository.dart';

class UnmappedNodeToMappedNodeParams{
  final String userId;
  final String controllerId;
  final String categoryId;
  final List<UnmappedCategoryNodeEntity> listOfUnmappedCategoryNodeEntity;
  UnmappedNodeToMappedNodeParams({
    required this.userId,
    required this.controllerId,
    required this.categoryId,
    required this.listOfUnmappedCategoryNodeEntity
  });
}


class UnmappedNodeToMappedNodeUsecase extends UseCase<Unit, UnmappedNodeToMappedNodeParams>{
  final MappingAndUnmappingNodesRepository repository;
  UnmappedNodeToMappedNodeUsecase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(UnmappedNodeToMappedNodeParams params)async{
    return repository.unmappedNodeToMapped(params);
  }

}