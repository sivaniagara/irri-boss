import 'package:dartz/dartz.dart';
import 'package:niagara_smart_drip_irrigation/core/error/failures.dart';
import 'package:niagara_smart_drip_irrigation/core/usecases/usecase.dart';
import '../entities/valve_flow_entity.dart';
import '../repositories/irrigation_settings_repository.dart';

class SaveValveFlowSettingsParams {
  final String userId;
  final String controllerId;
  final String subUserId;
  final ValveFlowEntity entity;

  SaveValveFlowSettingsParams({
    required this.userId,
    required this.controllerId,
    required this.subUserId,
    required this.entity,
  });
}

class SaveValveFlowSettingsUsecase extends UseCase<void, SaveValveFlowSettingsParams> {
  final IrrigationSettingsRepository repository;

  SaveValveFlowSettingsUsecase({required this.repository});

  @override
  Future<Either<Failure, void>> call(SaveValveFlowSettingsParams params) {
    return repository.saveValveFlowSettings(
      userId: params.userId,
      controllerId: params.controllerId,
      subUserId: params.subUserId,
      entity: params.entity,
    );
  }
}