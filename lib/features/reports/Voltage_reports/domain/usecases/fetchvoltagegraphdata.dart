import '../repositories/voltage_repo.dart';
import '../entities/voltage_entities.dart';

class FetchVoltageGraphData {
  final VoltageGraphRepository repository;

  FetchVoltageGraphData({required this.repository});

  Future<VoltageGraphEntities> call({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) {
    return repository.getGraphData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
