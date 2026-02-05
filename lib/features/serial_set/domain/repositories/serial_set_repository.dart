import 'package:dartz/dartz.dart';
import '../../../../../../../core/error/failures.dart';
import '../entities/serial_set_entity.dart';

abstract class SerialSetRepository {
  Future<Either<Failure, SerialSetEntity>> getSerialSet({
    required String userId,
    required String controllerId,
    required String subUserId,
  });

  Future<Either<Failure, void>> saveSerialSet({
    required String userId,
    required String controllerId,
    required String subUserId,
    required SerialSetEntity entity,
    required String sentSms,
  });

  Future<Either<Failure, void>> sendMqttCommand({
    required String deviceId,
    required String command,
    required String userId,
    required String controllerId,
    required String subUserId,
    required String sentSms,
  });
}
