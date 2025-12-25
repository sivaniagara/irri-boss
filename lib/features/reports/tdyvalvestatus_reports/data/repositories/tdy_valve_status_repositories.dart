import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/domain/entities/motor_cyclic_entities.dart';

import '../../domain/entities/tdy_valve_status_entities.dart';
import '../../domain/repositories/tdy_valve_status_repo.dart';
import '../datasources/tdy_valve_status_datasource.dart';

 
 
class TdyValveStatusRepositoryImpl implements TdyValveStatusRepository {
  final TdyValveStatusRemoteDataSource dataSource;

  TdyValveStatusRepositoryImpl({required this.dataSource});

  @override
Future<TdyValveStatusEntity> getTdyValveStatusData({
     required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String program,
  }) async {
    final model = await dataSource.TdyValveStatusData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      program: program,
    );
    return TdyValveStatusEntity(code: model.code,
        message: model.message,
        data: model.data.map((s) {
      return  TdyValveStatusDatumEntity(zone: s.zone, duration: s.duration, litres: s.litres, zonePlace: s.zonePlace,totalFlow: s.totalFlow);
        }).toList(), totalFlow: model.totalFlow,
         );

  }



}
