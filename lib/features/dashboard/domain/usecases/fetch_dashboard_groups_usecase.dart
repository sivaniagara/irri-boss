import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:go_router/go_router.dart';
import 'package:niagara_smart_drip_irrigation/features/dashboard/domain/entities/group_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/dashboard_repository.dart';

class FetchDashboardGroups extends UseCase<dynamic, DashboardGroupsParams> {
  final DashboardRepository repository;
  FetchDashboardGroups(this.repository);

  @override
  Future<Either<Failure, List<GroupDetailsEntity>>> call(DashboardGroupsParams params) {
    return repository.fetchDashboardGroups(params.userId, params.routeState);
  }
}

class DashboardGroupsParams extends Equatable {
  final int userId;
  final GoRouterState routeState;
  const DashboardGroupsParams(this.userId, this.routeState);

  @override
  List<Object?> get props => [userId];
}