



import '../entities/motor_cyclic_entities.dart';

abstract class MotorCyclicRepository {
  Future<MotoCyclicEntity> getMotorCyclicData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}