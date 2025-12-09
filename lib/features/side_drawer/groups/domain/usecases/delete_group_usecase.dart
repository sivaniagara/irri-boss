import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../repositories/fetch_group_repository.dart';

class DeleteGroupUsecase extends UseCase<dynamic, DeleteGroupParams> {
  final GroupRepository fetchGroupRepository;
  DeleteGroupUsecase(this.fetchGroupRepository);

  @override
  Future<Either<Failure, dynamic>> call(DeleteGroupParams params) {
    return fetchGroupRepository.deleteGroup(params.userId, params.groupId);
  }
}

class DeleteGroupParams extends Equatable {
  final int userId;
  final int groupId;
  const DeleteGroupParams(this.userId, this.groupId);

  @override
  List<Object?> get props => [userId, groupId];
}