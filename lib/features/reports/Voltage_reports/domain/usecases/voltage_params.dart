import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/domain/entities/voltage_entities.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/domain/repositories/voltage_repo.dart';




class FetchVoltageGraphData {
  final VoltageGraphRepository repository;

  FetchVoltageGraphData(this.repository);

  Future<VoltageGraphEntities> call({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) async {
    return await repository.getGraphData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
