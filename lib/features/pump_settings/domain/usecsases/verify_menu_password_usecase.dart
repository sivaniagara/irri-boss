import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/pump_settings_repository.dart';

class VerifyMenuPasswordUsecase extends UseCase<String, VerifyMenuPasswordParams> {
  final PumpSettingsRepository repository;

  VerifyMenuPasswordUsecase({required this.repository});

  @override
  Future<Either<Failure, String>> call(VerifyMenuPasswordParams params) async {
    return await repository.verifyMenuPassword(params.password, params.modelId);
  }
}

class VerifyMenuPasswordParams {
  final String password;
  final int modelId;

  VerifyMenuPasswordParams({required this.password, required this.modelId});
}
