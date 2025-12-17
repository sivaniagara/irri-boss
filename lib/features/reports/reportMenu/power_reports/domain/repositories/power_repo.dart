
import '../entities/power_entities.dart';



abstract class PowerGraphRepository {
  Future<PowerGraphEntity> getGraphData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}