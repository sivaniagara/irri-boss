import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';
import '../entities/mapped_node_entity.dart';
import '../repositories/mapping_and_unmapping_nodes_repository.dart';

class DeleteMappedNodeParams{
  final String userId;
  final String controllerId;
  final String deviceId;
  final MappedNodeEntity mappedNodeEntity;

  DeleteMappedNodeParams({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.mappedNodeEntity,
  });
}

class DeleteMappedNodeUsecase extends UseCase<Unit, DeleteMappedNodeParams>{
  final MappingAndUnmappingNodesRepository repository;
  DeleteMappedNodeUsecase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(DeleteMappedNodeParams params)async{
    return repository.deleteMappedNode(params);
  }
}