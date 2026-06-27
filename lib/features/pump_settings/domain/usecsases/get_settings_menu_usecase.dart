import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/pump_settings_repository.dart';
import '../entities/menu_item_entity.dart';

class GetPumpSettingsMenuUsecase extends UseCase<List<MenuItemEntity>, GetPumpSettingsMenuParams> {
  final PumpSettingsRepository pumpSettingsRepository;
  GetPumpSettingsMenuUsecase({required this.pumpSettingsRepository});

  @override
  Future<Either<Failure, List<MenuItemEntity>>> call(GetPumpSettingsMenuParams params) {
    return pumpSettingsRepository.getSettingsMenuList(params.userId, params.subUserId, params.controllerId, params.modelId);
  }
}

class GetPumpSettingsMenuParams extends Equatable {
  final int userId;
  final int subUserId;
  final int controllerId;
  final int modelId;

  const GetPumpSettingsMenuParams({
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.modelId,
  });

  @override
  List<Object?> get props => [userId, subUserId, controllerId];
}