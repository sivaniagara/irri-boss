import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/domain/entities/motor_cyclic_entities.dart';

import '../../domain/entities/standalone_entities.dart';
import '../../domain/repositories/standalone_repo.dart';
import '../datasources/standalone_datasource.dart';

 
class StandaloneRepositoryImpl implements StandaloneRepository {
  final StandaloneRemoteDataSource dataSource;

  StandaloneRepositoryImpl({required this.dataSource});

  @override
Future<StandaloneEntity> getStandaloneData({
     required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) async {
    final model = await dataSource.StandaloneData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
    return StandaloneEntity(code: model.code,
        message: model.message,
        data: model.data.map((s) {
      return StandaloneDatumEntity(date: s.date, zone: s.zone, onTime: s.onTime, offDate: s.offDate, offTime: s.offTime, duration: s.duration, dateTime: s.dateTime );
        }).toList(),
         totalDuration: model.totDuration,
        totalFlow: model.totFlow,
        powerDuration: model.powerDuration,
        controllerDuration: model.ctrlDuration,
        controllerDuration1: model.ctrlDuration1);

  }



}
