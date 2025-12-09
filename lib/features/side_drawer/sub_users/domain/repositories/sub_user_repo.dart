import 'package:dartz/dartz.dart';
import '../../../../../core/error/failures.dart';
import '../sub_users_domain.dart';

abstract class SubUserRepo {
  Future<Either<Failure, List<SubUserEntity>>> getSubUsers(int userId);
  Future<Either<Failure, SubUserDetailsEntity>> getSubUserDetails(GetSubUserDetailsParams subUserDetailsParams);
  Future<Either<Failure, String>> updateSubUserDetails(UpdateSubUserDetailsParams subUserDetailsEntity);
  Future<Either<Failure, dynamic>> getSubUserByPhone(GetSubUserByPhoneParams getSubUserByPhoneParams);
}