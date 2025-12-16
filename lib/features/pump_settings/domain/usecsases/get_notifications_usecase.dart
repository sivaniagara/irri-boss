import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notifications_entity.dart';
import '../repositories/pump_settings_repository.dart';

class GetNotificationsUsecase extends UseCase<List<NotificationsEntity>, GetNotificationsParams> {
  final PumpSettingsRepository pumpSettingsRepository;
  GetNotificationsUsecase({required this.pumpSettingsRepository});

  @override
  Future<Either<Failure, List<NotificationsEntity>>> call(GetNotificationsParams params) {
    return pumpSettingsRepository.getNotifications(params.userId, params.subUserId, params.controllerId);
  }
}

class GetNotificationsParams extends Equatable {
  final int userId;
  final int subUserId;
  final int controllerId;

  const GetNotificationsParams({
    required this.userId,
    required this.subUserId,
    required this.controllerId,
  });

  @override
  List<Object?> get props => [userId, subUserId, controllerId];
}