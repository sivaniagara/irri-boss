import 'package:niagara_smart_drip_irrigation/features/reports/Motor_cyclic_reports/domain/entities/motor_cyclic_entities.dart';

import '../../domain/entities/zone_duration_entities.dart';
import '../../domain/repositories/zone_duration_repo.dart';
import '../datasources/zone_duration_datasource.dart';


class ZoneDurationRepositoryImpl implements ZoneDurationRepository {
  final ZoneDurationRemoteDataSource dataSource;

  ZoneDurationRepositoryImpl({required this.dataSource});

  @override
  Future<ZoneDurationEntity> getZoneDurationData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
  }) async {
    final model = await dataSource.ZoneDurationData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
    );

    return ZoneDurationEntity(
      code: model.code,
      message: model.message,

      /// 🔹 MAP LIST PROPERLY
      data: model.data.map((z) {
        return ZoneDurationDatumEntity(
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
          ec: z.ec,
          ph: z.ph,
          program: z.program,
          vrb: z.vrb,
          c1: z.c1,
          c2: z.c2,
          c3: z.c3,
        );
      }).toList(),

      totDuration: model.totDuration,
      totFlow: model.totFlow,
      powerDuration: model.powerDuration,
      ctrlDuration: model.ctrlDuration,
      ctrlDuration1: model.ctrlDuration1,
    );
  }
}
