



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