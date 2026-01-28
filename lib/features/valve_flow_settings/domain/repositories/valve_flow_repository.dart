import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/valve_flow_entity.dart';

abstract class ValveFlowRepository {
  Future<Either<Failure, ValveFlowEntity>> getValveFlowSetting({
    required String userId,
    required String controllerId,
    required String subUserId,
  });

<<<<<<< HEAD
=======
  Future<Either<Failure, void>> publishValveFlowSms({
    required String userId,
    required String controllerId,
    required String subUserId,
    required String sentSms,
  });

>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
  Future<Either<Failure, void>> saveValveFlowSettings({
    required String userId,
    required String controllerId,
    required String subUserId,
    required ValveFlowEntity entity,
<<<<<<< HEAD
    required String sentSms,
=======
>>>>>>> d1429699b9e6a75b60f2d2f36b6708390758b021
  });
}
