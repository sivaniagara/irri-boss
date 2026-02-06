import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/controller_entity.dart';
import '../repositories/dashboard_repository.dart';

class FetchControllers extends UseCase<List<ControllerEntity>, UserGroupParams> {
  final DashboardRepository repository;
  FetchControllers(this.repository);

  @override
  Future<Either<Failure, List<ControllerEntity>>> call(UserGroupParams params) {
    return repository.fetchControllers(params.userId, params.groupId, params.routeState);
  }
}

class UserGroupParams extends Equatable {
  final int userId;
  final int groupId;
  final GoRouterState routeState;
  const UserGroupParams(this.userId, this.groupId, this.routeState);

  @override
  List<Object?> get props => [userId, groupId, routeState];
}