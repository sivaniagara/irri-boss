


import '../entities/power_entities.dart';
import '../repositories/power_repo.dart';

class FetchPowerGraphData {
  final PowerGraphRepository repository;

  FetchPowerGraphData({required this.repository});

  Future<PowerGraphEntity> call({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
    required int sum,
  }) {
    return repository.getGraphData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
      sum: sum,
    );
  }
}
