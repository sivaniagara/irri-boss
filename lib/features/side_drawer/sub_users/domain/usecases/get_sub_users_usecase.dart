import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/sub_user_repo.dart';

class GetSubUsersUsecase extends UseCase<dynamic, GetSubUsersParams> {
  final SubUserRepo subUserRepo;

  GetSubUsersUsecase({required this.subUserRepo});

  @override
  Future<Either<Failure, dynamic>> call(GetSubUsersParams params) {
    return subUserRepo.getSubUsers(params.userId);
  }
}

class GetSubUsersParams extends Equatable{
  final int userId;
  const GetSubUsersParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}