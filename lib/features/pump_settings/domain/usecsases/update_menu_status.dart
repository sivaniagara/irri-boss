import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:niagara_smart_drip_irrigation/features/pump_settings/domain/entities/settings_menu_entity.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/repositories/pump_settings_repository.dart';

class UpdateMenuStatusUsecase extends UseCase<String, UpdateMenuStatusParams> {
  final PumpSettingsRepository pumpSettingsRepository;
  UpdateMenuStatusUsecase({required this.pumpSettingsRepository});

  @override
  Future<Either<Failure, String>> call(UpdateMenuStatusParams params) {
    return pumpSettingsRepository.updateMenuStatus(params.userId, params.subUserId, params.controllerId, params.menuEntity);
  }
}

class UpdateMenuStatusParams extends Equatable {
  final int userId;
  final int subUserId;
  final int controllerId;
  final SettingsMenuEntity menuEntity;

  const UpdateMenuStatusParams({
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.menuEntity,
  });

  @override
  List<Object?> get props => [userId, subUserId, controllerId, menuEntity];
}