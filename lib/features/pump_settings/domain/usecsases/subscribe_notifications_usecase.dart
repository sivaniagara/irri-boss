import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/pump_settings_repository.dart';

class SubscribeNotificationsUsecase extends UseCase<String, SubscribeNotificationsParams> {
  final PumpSettingsRepository pumpSettingsRepository;
  SubscribeNotificationsUsecase({required this.pumpSettingsRepository});

  @override
  Future<Either<Failure, String>> call(SubscribeNotificationsParams params) {
    return pumpSettingsRepository.subscribeNotifications(params.userId, params.subUserId, params.controllerId, params.body);
  }
}

class SubscribeNotificationsParams extends Equatable {
  final int userId;
  final int subUserId;
  final int controllerId;
  final Map<String, dynamic> body;

  const SubscribeNotificationsParams({
    required this.userId,
    required this.subUserId,
    required this.controllerId,
    required this.body,
  });

  @override
  List<Object?> get props => [userId, subUserId, controllerId, body];
}