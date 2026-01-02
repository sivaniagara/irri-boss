import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/domain/entities/motor_cyclic_entities.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/flow_graph_reports/domain/entities/flow_graph_entities.dart';

import '../../domain/repositories/flow_graph_repo.dart';
import '../datasources/flow_graph_datasource.dart';
 

 

 
 
class FlowGraphRepositoryImpl implements FlowGraphRepository {
  final FlowGraphRemoteDataSource dataSource;

  FlowGraphRepositoryImpl({required this.dataSource});

  @override
Future<FlowGraphEntities> getFlowGraphData({
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
    return FlowGraphEntities(code: model.code,
        message: model.message,
        data: model.data.map((c){
          return FlowGraphDataEntity(date: c.date, totalFlow: c.totalFlow, totalRunTime: c.totalRunTime, total3PhaseOnTime: c.total3PhaseOnTime, total2PhaseOnTime: c.total2PhaseOnTime, totalPowerOnTime: c.totalPowerOnTime);
        }).toList(),
  );
  }



}
