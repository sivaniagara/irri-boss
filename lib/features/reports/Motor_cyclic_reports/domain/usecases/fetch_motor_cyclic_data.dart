import '../entities/motor_cyclic_entities.dart';
import '../repositories/motor_cyclic_repo.dart';

class FetchMotorCyclicData {
  final MotorCyclicRepository repository;

  FetchMotorCyclicData({required this.repository});

  Future<MotoCyclicEntity> call({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) {
    return repository.getMotorCyclicData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
