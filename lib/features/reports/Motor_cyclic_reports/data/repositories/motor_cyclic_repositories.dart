import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/domain/entities/motor_cyclic_entities.dart';

import '../../domain/repositories/motor_cyclic_repo.dart';
import '../datasources/motor_cyclic_datasource.dart';

class MotorCyclicRepositoryImpl implements MotorCyclicRepository {
  final MotorCyclicRemoteDataSource dataSource;

  MotorCyclicRepositoryImpl({required this.dataSource});

  @override
Future<MotoCyclicEntity> getMotorCyclicData({
     required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) async {
    final model = await dataSource.MotorCyclicData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
    return MotoCyclicEntity(
      code: model.code,
      message: model.message,
      data: model.data.map((d) {
        return MotoCyclicDatumEntity(
          program: d.program,
          ctrlMsg: d.ctrlMsg,
          zoneList: d.zoneList.map((z) {
            return MotoCyclicZoneEntity(
              date: z.date,
              zone: z.zone,
              onTime: z.onTime,
              offDate: z.offDate,
              offTime: z.offTime,
              duration: z.duration,
              dateTime: z.dateTime,
              flow: z.flow,
              pressure: z.pressure,
              pressureIn: z.pressureIn,
              pressureOut: z.pressureOut,
              wellLevel: z.wellLevel,
              wellPercentage: z.wellPercentage,
              ph: z.ph,
              ec: z.ec,
              vrb: z.vrb,
              c1: z.c1,
              c2: z.c2,
              c3: z.c3,
            );
          }).toList(), // ✅ VERY IMPORTANT
        );
      }).toList(), // ✅ VERY IMPORTANT
      totDuration: model.totDuration,
      totFlow: model.totFlow,
      powerDuration: model.powerDuration,
      ctrlDuration: model.ctrlDuration,
      ctrlDuration1: model.ctrlDuration1,
    );

  }



}
