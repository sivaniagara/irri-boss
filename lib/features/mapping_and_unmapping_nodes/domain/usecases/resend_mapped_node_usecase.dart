

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/mapped_node_entity.dart';
import '../repositories/mapping_and_unmapping_nodes_repository.dart';

class ResendMappedNodeUsecase implements UseCase<Unit, ResendMappedNodeParams> {
  final MappingAndUnmappingNodesRepository repository;

  ResendMappedNodeUsecase({required this.repository});

  @override
  Future<Either<Failure, Unit>> call(ResendMappedNodeParams params) async {
    return await repository.resendMappedNode(params);
  }
}

class ResendMappedNodeParams {
  final String userId;
  final String controllerId;
  final String deviceId;
  final MappedNodeEntity mappedNodeEntity;

  ResendMappedNodeParams({
    required this.userId,
    required this.controllerId,
    required this.deviceId,
    required this.mappedNodeEntity,
  });
}