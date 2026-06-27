import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/pump_settings_repository.dart';

class SendPumpSettingsUsecase extends UseCase<String, SendPumpSettingsParams> {
  final PumpSettingsRepository pumpSettingsRepository;
  SendPumpSettingsUsecase({required this.pumpSettingsRepository});

  @override
  Future<Either<Failure, String>> call(SendPumpSettingsParams params) {
    return pumpSettingsRepository.sendPumpSettings(params.userId, params.subUserId, params.controllerId, params.menuItemEntity, params.sentSms, params.modelId);
  }
}

class SendPumpSettingsParams extends Equatable {
  final int userId;
  final int subUserId;
  final int controllerId;
  final int menuId;
  final int modelId;
  final String sentSms;
  final MenuItemEntity menuItemEntity;

  const SendPumpSettingsParams({
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.menuId,
    required this.modelId,
    required this.menuItemEntity,
    required this.sentSms
  });

  @override
  List<Object?> get props => [userId, subUserId, controllerId, menuId, modelId, menuItemEntity, sentSms];
}