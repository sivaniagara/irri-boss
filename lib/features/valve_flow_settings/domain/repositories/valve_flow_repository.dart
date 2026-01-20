import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/valve_flow_entity.dart';

abstract class ValveFlowRepository {
  Future<Either<Failure, ValveFlowEntity>> getValveFlowSetting({
    required String userId,
    required String controllerId,
    required String subUserId,
  });

  Future<Either<Failure, void>> saveValveFlowSettings({
    required String userId,
    required String controllerId,
    required String subUserId,
    required ValveFlowEntity entity,
    required String sentSms,
  });
}
