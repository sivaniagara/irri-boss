import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/alarm_entity.dart';

abstract class AlarmRepository {
  Future<Either<Failure, AlarmEntity>> getAlarmSetting({
    required String userId,
    required String controllerId,
    required String subUserId,
  });

  Future<Either<Failure, void>> saveAlarmSettings({
    required String userId,
    required String controllerId,
    required String subUserId,
    required AlarmEntity entity,
    required String sentSms,
  });
}
