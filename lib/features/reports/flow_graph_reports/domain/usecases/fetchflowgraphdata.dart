import '../entities/flow_graph_entities.dart';
import '../repositories/flow_graph_repo.dart';

class FetchFlowGraphData {
  final FlowGraphRepository repository;

  FetchFlowGraphData({required this.repository});

  Future<FlowGraphEntities> call({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) {
    return repository.getFlowGraphData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
