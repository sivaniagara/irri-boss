 import '../entities/tdy_valve_status_entities.dart';
 import '../repositories/tdy_valve_status_repo.dart';

class FetchTdyValveStatusData {
  final TdyValveStatusRepository repository;

  FetchTdyValveStatusData({required this.repository});

  Future<TdyValveStatusEntity> call({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String program,
  }) {
    return repository.getTdyValveStatusData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      program: program,
    );
  }
}
