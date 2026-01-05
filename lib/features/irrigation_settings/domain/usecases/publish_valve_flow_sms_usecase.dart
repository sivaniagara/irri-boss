import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';
import '../repositories/irrigation_settings_repository.dart';

class PublishValveFlowSmsParams {
  final String userId;
  final String controllerId;
  final String subUserId;
  final String sentSms;

  PublishValveFlowSmsParams({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.sentSms,
  });
}

class PublishValveFlowSmsUsecase extends UseCase<void, PublishValveFlowSmsParams> {
  final IrrigationSettingsRepository repository;

  PublishValveFlowSmsUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(PublishValveFlowSmsParams params) {
    return repository.publishValveFlowSms(
      userId: params.userId,
      controllerId: params.controllerId,
      subUserId: params.subUserId,
      sentSms: params.sentSms,
    );
  }
}