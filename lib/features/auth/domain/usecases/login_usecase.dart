import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../auth_domain.dart';

class LoginWithPassword extends UseCase<RegisterDetailsEntity, LoginParams> {
  final AuthRepository repository;
  LoginWithPassword(this.repository);

  @override
  Future<Either<Failure, RegisterDetailsEntity>> call(LoginParams params) {
    return repository.loginWithPassword(params.phone, params.password);
  }
}

class SendOtp extends UseCase<String, PhoneParams> {
  final AuthRepository repository;
  SendOtp(this.repository);

  @override
  Future<Either<Failure, String>> call(PhoneParams params) {
    final fullPhone = params.phone.startsWith('+') ? params.phone : params.countryCode + params.phone;
    return repository.sendOtp(fullPhone);
  }
}

class VerifyOtp extends UseCase<RegisterDetailsEntity, VerifyOtpParams> {
  final AuthRepository repository;
  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, RegisterDetailsEntity>> call(VerifyOtpParams params) {
    return repository.verifyOtp(params.verificationId, params.otp, params.countryCode);
  }
}

/// Logout use case
class Logout extends UseCase<void, NoParams> {
  final AuthRepository repository;
  Logout(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.logout();
  }
}

/// Check Phone Number use case
class CheckPhoneNumber extends UseCase<bool, PhoneParams> {
  final AuthRepository repository;
  CheckPhoneNumber(this.repository);

  @override
  Future<Either<Failure, bool>> call(PhoneParams params) {
    return repository.checkPhoneNumber(params.phone, params.countryCode);
  }
}

class SignUp extends UseCase<RegisterDetailsEntity, SignUpParams> {
  final AuthRepository repository;
  SignUp(this.repository);

  @override
  Future<Either<Failure, RegisterDetailsEntity>> call(SignUpParams params) {
    return repository.signUp(params);
  }
}

class UpdateProfile extends UseCase<RegisterDetailsEntity, UpdateProfileParams> {
  final AuthRepository repository;
  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, RegisterDetailsEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(params);
  }
}