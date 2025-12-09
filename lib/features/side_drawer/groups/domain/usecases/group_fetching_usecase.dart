import 'dart:core';

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/fetch_group_repository.dart';

class GroupFetchingUsecase extends UseCase<dynamic, GroupFetchParams> {
  final GroupRepository fetchGroupRepository;
  GroupFetchingUsecase(this.fetchGroupRepository);

  @override
  Future<Either<Failure, dynamic>> call(GroupFetchParams params) {
    return fetchGroupRepository.fetchGroupEntity(params.userId);
  }
}

class GroupFetchParams extends Equatable{
  final int userId;
  const  GroupFetchParams(this.userId);

  @override
  // TODO: implement props
  List<Object?> get props => [userId];
}