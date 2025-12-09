import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/features/side_drawer/sub_users/domain/entities/sub_user_details_entity.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/usecases/usecase.dart';
import '../repositories/sub_user_repo.dart';

class UpdateSubUserDetailsUseCase extends UseCase<dynamic, UpdateSubUserDetailsParams> {
  final SubUserRepo subUserRepo;
  UpdateSubUserDetailsUseCase({required this.subUserRepo});

  @override
  Future<Either<Failure, dynamic>> call(UpdateSubUserDetailsParams params) {
    return subUserRepo.updateSubUserDetails(params);
  }
}

class UpdateSubUserDetailsParams extends Equatable {
  final SubUserDetailsEntity subUserDetailsEntity;
  final int userId;
  final bool isNewSubUser;
  final bool isDelete;
  const UpdateSubUserDetailsParams({required this.subUserDetailsEntity, required this.userId, required this.isNewSubUser, required this.isDelete});

  @override
  List<Object?> get props => [subUserDetailsEntity, userId, isNewSubUser];
}