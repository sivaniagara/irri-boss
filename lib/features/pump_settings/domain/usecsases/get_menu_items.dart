import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/menu_item_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/pump_settings_repository.dart';

class GetPumpSettingsUsecase extends UseCase<MenuItemEntity, GetPumpSettingsParams> {
  final PumpSettingsRepository pumpSettingsRepository;
  GetPumpSettingsUsecase({required this.pumpSettingsRepository});

  @override
  Future<Either<Failure, MenuItemEntity>> call(GetPumpSettingsParams params) {
    return pumpSettingsRepository.getPumpSettings(params.userId, params.subUserId, params.controllerId, params.menuId);
  }
}

class GetPumpSettingsParams extends Equatable {
  final int userId;
  final int subUserId;
  final int controllerId;
  final int menuId;

  const GetPumpSettingsParams({
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.menuId,
  });

  @override
  List<Object?> get props => [userId, subUserId, controllerId, menuId];
}