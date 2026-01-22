import 'package:dartz/dartz.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failures.dart';
import '../entities/group_entity.dart';
import '../entities/controller_entity.dart';

abstract class DashboardRepository {
  Future<Either<Failure, List<GroupDetailsEntity>>> fetchDashboardGroups(int userId, GoRouterState routeState);
  Future<Either<Failure, List<ControllerEntity>>> fetchControllers(int userId, int groupId, GoRouterState routeState);
}