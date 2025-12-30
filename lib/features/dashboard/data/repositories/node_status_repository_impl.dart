import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/data/datasources/node_status_data_source.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/entities/node_status_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/repositories/node_status_repository.dart';

import '../../../../core/error/exceptions.dart';

class NodeStatusRepositoryImpl implements NodeStatusRepository {
  final NodeStatusDataSource nodeStatusDataSource;

  NodeStatusRepositoryImpl({required this.nodeStatusDataSource});

  @override
  Future<Either<Failure, List<NodeStatusEntity>>> getNodeStatus(int userId, int controllerId, int subuserId) async{
    try {
      final response = await nodeStatusDataSource.getNodeStatus(userId, controllerId, subuserId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch dashboard groups: $e'));
    }
  }
}