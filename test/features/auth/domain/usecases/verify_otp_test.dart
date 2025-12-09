import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/domain/entities/user_entity.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/domain/repositories/auth_repository.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/domain/usecases/login_params.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/domain/usecases/login_usecase.dart';

import '../repositories/auth_repository_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late VerifyOtp usecase;
  late MockAuthRepository mockAuthRepository;
  late VerifyOtpParams params;
  late RegisterDetailsEntity tRegisterDetails;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = VerifyOtp(mockAuthRepository);
    
    params = const VerifyOtpParams(
      verificationId: 'verification123',
      otp: '123456',
      countryCode: '+1',
    );

    tRegisterDetails = RegisterDetailsEntity(
      mqttIPAddress: '88888',
      mqttUserName: 'niagara',
      mqttPassword: 'niagara@123',
      groupDetails: [],
      userDetails: UserEntity(
          id: 1,
          name: "test",
          mobile: "1234567890",
          userType: 1,
          deviceToken: "dhdf",
          mobCctv: "",
          webCctv: "",
          altPhoneNum: []
      ),
    );
  });

  test(
    'should verify OTP through the repository',
    () async {
      // arrange
      when(mockAuthRepository.verifyOtp("1234567890", "123456", "+91"))
          .thenAnswer((_) async => Right(tRegisterDetails));
      
      // act
      final result = await usecase(params);
      
      // assert
      expect(result, Right(tRegisterDetails));
      verify(mockAuthRepository.verifyOtp(
        params.verificationId,
        params.otp,
        params.countryCode,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return server failure when repository call fails',
    () async {
      // arrange
      when(mockAuthRepository.verifyOtp("1234567890", "123456", "+91"))
          .thenAnswer((_) async => Left(ServerFailure()));
      
      // act
      final result = await usecase(params);
      
      // assert
      expect(result, Left(ServerFailure()));
      verify(mockAuthRepository.verifyOtp(
        params.verificationId,
        params.otp,
        params.countryCode,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return invalid otp failure when OTP is invalid',
    () async {
      // arrange
      when(mockAuthRepository.verifyOtp("1234567890", "123456", "+91"))
          .thenAnswer((_) async => Left(AuthFailure("Test auth failure")));
      
      // act
      final result = await usecase(params);
      
      // assert
      expect(result, Left(AuthFailure("Test auth failure")));
      verify(mockAuthRepository.verifyOtp(
        params.verificationId,
        params.otp,
        params.countryCode,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
