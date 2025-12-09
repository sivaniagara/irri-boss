import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';

import '../../../../../core/usecases/usecase.dart';
import '../repositories/sub_user_repo.dart';

class GetSubUserByPhoneUsecase extends UseCase<dynamic, GetSubUserByPhoneParams> {
  final SubUserRepo subUserRepo;
  GetSubUserByPhoneUsecase({required this.subUserRepo});

  @override
  Future<Either<Failure, dynamic>> call(GetSubUserByPhoneParams params) {
    return subUserRepo.getSubUserByPhone(params);
  }
}

class GetSubUserByPhoneParams extends Equatable {
  final String phoneNumber;
  const GetSubUserByPhoneParams({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}