import 'package:dartz/dartz.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../datasources/dashboard_remote_data_source.dart';
import '../../domain/dashboard_domain.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remote;

  DashboardRepositoryImpl({required this.remote});

  @override
  Future<Either<Failure, List<GroupDetailsEntity>>> fetchDashboardGroups(int userId, GoRouterState routeState) async {
    try {
      final response = await remote.fetchDashboardGroups(userId, routeState);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch dashboard groups: $e'));
    }
  }

  @override
  Future<Either<Failure, List<ControllerEntity>>> fetchControllers(int userId, int groupId, GoRouterState routeState) async {
    try {
      final response = await remote.fetchControllers(userId, groupId, routeState);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Failed to fetch controllers: $e'));
    }
  }
}