import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/settings_menu_entity.dart';
import '../../domain/repositories/pump_settings_repository.dart';

class GetPumpSettingsMenuUsecase extends UseCase<List<SettingsMenuEntity>, GetPumpSettingsMenuParams> {
  final PumpSettingsRepository pumpSettingsRepository;
  GetPumpSettingsMenuUsecase({required this.pumpSettingsRepository});

  @override
  Future<Either<Failure, List<SettingsMenuEntity>>> call(GetPumpSettingsMenuParams params) {
    return pumpSettingsRepository.getSettingsMenuList(params.userId, params.subUserId, params.controllerId);
  }
}

class GetPumpSettingsMenuParams extends Equatable {
  final int userId;
  final int subUserId;
  final int controllerId;

  const GetPumpSettingsMenuParams({
    required this.userId,
    required this.subUserId,
    required this.controllerId
  });

  @override
  List<Object?> get props => [userId, subUserId, controllerId];
}