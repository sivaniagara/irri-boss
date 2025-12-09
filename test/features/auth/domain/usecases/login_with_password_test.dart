import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/domain/entities/user_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/domain/repositories/auth_repository.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/domain/usecases/login_params.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginWithPassword useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginWithPassword(mockAuthRepository);
  });

  const tPhone = "9999999999";
  const tPassword = "password123";
  const tName = "nameSaravanan";
  final tUser = UserEntity(id: 1, mobile: tPhone, name: tName, deviceToken: '', userType: 0, mobCctv: '', webCctv: '', altPhoneNum: []);
  final tUserDetails = RegisterDetailsEntity(userDetails: tUser, mqttIPAddress: '', mqttUserName: '', mqttPassword: '', groupDetails: []);

  test("should return User when login succeeds", () async {
    when(() => mockAuthRepository.loginWithPassword(tPhone, tPassword))
        .thenAnswer((_) async => Right(tUserDetails));

    final result = await useCase(LoginParams(phone: tPhone, password: tPassword));

    expect(result, Right(tUser));
    verify(() => mockAuthRepository.loginWithPassword(tPhone, tPassword));
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test("should return Failure when login fails", () async {
    when(() => mockAuthRepository.loginWithPassword(tPhone, tPassword))
        .thenAnswer((_) async => Left(ServerFailure()));

    final result = await useCase(LoginParams(phone: tPhone, password: tPassword));

    expect(result, Left(ServerFailure()));
  });
}
