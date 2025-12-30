

import '../../domain/entities/flow_graph_entities.dart';
import '../../domain/repositories/flow_graph_repo.dart';
import '../datasources/flow_graph_datasource.dart';

class FlowGraphRepositoryImpl implements FlowGraphRepository {
  final FlowGraphRemoteDataSource dataSource;

  FlowGraphRepositoryImpl({required this.dataSource});

  Future<FlowGraphEntities> FlowGraphData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) async {
    final model = await dataSource.FlowGraphData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );

    return FlowGraphEntities(
      code: model.code,
      message: model.message,
      data: (model.data ?? []).map((f) {
        return FlowGraphDataEntity(
          date: f.date,
          totalFlow: f.totalFlow,
          totalRunTime: f.totalRunTime,
          total3PhaseOnTime: f.total3PhaseOnTime,
          total2PhaseOnTime: f.total2PhaseOnTime,
          totalPowerOnTime: f.totalPowerOnTime,
        );
      }).toList(),
    );
  }

  @override
  Future<FlowGraphEntities> getFlowGraphData({required int userId, required int subuserId, required int controllerId, required String fromDate, required String toDate}) {
    // TODO: implement getFlowGraphData
    throw UnimplementedError();
  }

}

