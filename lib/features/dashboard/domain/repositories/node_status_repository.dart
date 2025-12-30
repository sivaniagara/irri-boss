import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/entities/node_status_entity.dart';

abstract class NodeStatusRepository {
  Future<Either<Failure, List<NodeStatusEntity>>> getNodeStatus(int userId, int controllerId, int subuserId);
}