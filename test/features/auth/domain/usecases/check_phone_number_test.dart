import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/domain/repositories/auth_repository.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/domain/usecases/login_params.dart';
import 'package:niagara_smart_drip_irrigation/features/auth/domain/usecases/login_usecase.dart';

import '../repositories/auth_repository_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late CheckPhoneNumber usecase;
  late MockAuthRepository mockAuthRepository;
  late PhoneParams params;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = CheckPhoneNumber(mockAuthRepository);
    
    params = const PhoneParams(
      '1234567890',
      '+1',
    );
  });

  test(
    'should check if phone number exists through the repository',
    () async {
      // arrange
      when(mockAuthRepository.checkPhoneNumber("123456789", "123456"))
          .thenAnswer((_) async => const Right(true));
      
      // act
      final result = await usecase(params);
      
      // assert
      expect(result, const Right(true));
      verify(mockAuthRepository.checkPhoneNumber(
        params.phone,
        params.countryCode,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return server failure when repository call fails',
    () async {
      // arrange
      when(mockAuthRepository.checkPhoneNumber("123456789", "123456"))
          .thenAnswer((_) async => Left(ServerFailure()));
      
      // act
      final result = await usecase(params);
      
      // assert
      expect(result, Left(ServerFailure()));
      verify(mockAuthRepository.checkPhoneNumber(
        params.phone,
        params.countryCode,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );

  test(
    'should return network failure when there is no internet connection',
    () async {
      // arrange
      when(mockAuthRepository.checkPhoneNumber("123456789", "123456"))
          .thenAnswer((_) async => Left(NetworkFailure()));
      
      // act
      final result = await usecase(params);
      
      // assert
      expect(result, Left(NetworkFailure()));
      verify(mockAuthRepository.checkPhoneNumber(
        params.phone,
        params.countryCode,
      ));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}
