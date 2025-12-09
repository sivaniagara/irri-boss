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
  late SignUp usecase;
  late MockAuthRepository mockAuthRepository;
  late SignUpParams params;
  late RegisterDetailsEntity tRegisterDetails;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = SignUp(mockAuthRepository);
    
    params = const SignUpParams(
      mobile: '+1234567890',
      name: 'Test User',
      userType: 1,
      addressOne: '123 Test St',
      country: 'Test Country',
      state: 'Test State',
      city: 'Test City',
      postalCode: '12345',
      email: 'test@example.com',
      password: 'password123', addressTwo: '', town: '', village: '', altPhone: '',
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
    'should sign up the user through the repository',
    () async {
      // arrange
      when(mockAuthRepository.signUp(params))
          .thenAnswer((_) async => Right(tRegisterDetails));
      
      // act
      final result = await usecase(params);
      
      // assert
      expect(result, Right(tRegisterDetails));
      verify(mockAuthRepository.signUp(params));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return server failure when repository call fails',
    () async {
      // arrange
      when(mockAuthRepository.signUp(params))
          .thenAnswer((_) async => Left(ServerFailure()));
      
      // act
      final result = await usecase(params);
      
      // assert
      expect(result, Left(ServerFailure()));
      verify(mockAuthRepository.signUp(params));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return network failure when there is no internet connection',
    () async {
      // arrange
      when(mockAuthRepository.signUp(params))
          .thenAnswer((_) async => Left(NetworkFailure()));
      
      // act
      final result = await usecase(params);
      
      // assert
      expect(result, Left(NetworkFailure()));
      verify(mockAuthRepository.signUp(params));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
