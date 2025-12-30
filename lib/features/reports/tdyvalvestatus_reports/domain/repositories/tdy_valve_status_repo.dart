

import '../entities/tdy_valve_status_entities.dart';

abstract class TdyValveStatusRepository {
  Future<TdyValveStatusEntity> getTdyValveStatusData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String program,
  });
}