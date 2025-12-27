import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/domain/entities/voltage_entities.dart';



abstract class VoltageGraphRepository {
  Future<VoltageGraphEntities> getGraphData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}