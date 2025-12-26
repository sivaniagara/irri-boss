import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/domain/entities/motor_cyclic_entities.dart';

import '../../domain/entities/zone_cyclic_entities.dart';
import '../../domain/repositories/zone_cyclic_repo.dart';
import '../datasources/zone_cyclic_datasource.dart';

 

 
 
class ZoneCyclicRepositoryImpl implements ZoneCyclicRepository {
  final ZoneCyclicRemoteDataSource dataSource;

  ZoneCyclicRepositoryImpl({required this.dataSource});

  @override
Future<ZoneCyclicEntity> getZoneCyclicData({
     required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) async {
    final model = await dataSource.ZoneCyclicData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );
    return ZoneCyclicEntity(code: model.code,
        message: model.message,
        data: model.data.map((c){
          return ZoneProgramEntity(program: c.program, zoneList: c.zoneList.map((z){
            return ZoneCyclicDetailEntity(date: z.date,
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
                ph: z.ph);
          }).toList());
        }).toList(),
        totalDuration: model.totDuration, 
        totalFlow: model.totFlow, 
        powerDuration: model.powerDuration, 
        controllerDuration: model.ctrlDuration, controllerDuration1: model.ctrlDuration1);
  }



}
