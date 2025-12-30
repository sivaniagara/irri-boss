import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/domain/entities/voltage_entities.dart';

import '../entities/flow_graph_entities.dart';



abstract class FlowGraphRepository {
  Future<FlowGraphEntities> getFlowGraphData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  });
}