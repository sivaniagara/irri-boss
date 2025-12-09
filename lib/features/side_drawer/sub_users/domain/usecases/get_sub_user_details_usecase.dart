import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';

import '../../../../../core/usecases/usecase.dart';
import '../repositories/sub_user_repo.dart';

class GetSubUserDetailsUsecase extends UseCase<dynamic, GetSubUserDetailsParams> {
  final SubUserRepo subUserRepo;
  GetSubUserDetailsUsecase({required this.subUserRepo});

  @override
  Future<Either<Failure, dynamic>> call(GetSubUserDetailsParams params) {
    return subUserRepo.getSubUserDetails(params);
  }
}

class GetSubUserDetailsParams extends Equatable {
  final int userId;
  final String subUserCode;
  final bool isNewSubUser;
  const GetSubUserDetailsParams({required this.userId, required this.subUserCode, required this.isNewSubUser});

  @override
  List<Object?> get props => [];
}