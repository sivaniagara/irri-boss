import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';

import '../repositories/fetch_group_repository.dart';

class EditGroupUsecase extends UseCase<dynamic, EditGroupParams> {
  final GroupRepository fetchGroupRepository;
  EditGroupUsecase(this.fetchGroupRepository);

  @override
  Future<Either<Failure, dynamic>> call(EditGroupParams params) {
    return fetchGroupRepository.editGroup(params.userId, params.groupName, params.groupId);
  }
}

class EditGroupParams extends Equatable{
  final int userId;
  final int groupId;
  final String groupName;
  const EditGroupParams(this.userId, this.groupId, this.groupName);

  @override
  // TODO: implement props
  List<Object?> get props => [userId, groupId, groupName];
}