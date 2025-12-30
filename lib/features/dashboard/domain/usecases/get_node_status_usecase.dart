import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/entities/node_status_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/repositories/node_status_repository.dart';

class GetNodeStatusUsecase extends UseCase<List<NodeStatusEntity>, GetNodeStatusParams> {
  final NodeStatusRepository nodeStatusRepository;

  GetNodeStatusUsecase({required this.nodeStatusRepository});

  @override
  Future<Either<Failure, List<NodeStatusEntity>>> call(GetNodeStatusParams params) async{
    return nodeStatusRepository.getNodeStatus(params.userId, params.subuserId, params.controllerId);
  }
}

class GetNodeStatusParams extends Equatable {
  final int userId, controllerId, subuserId;

  const GetNodeStatusParams({
    required this.userId,
    required this.controllerId,
    required this.subuserId
  });

  @override
  List<Object?> get props => [userId, controllerId, subuserId];
}