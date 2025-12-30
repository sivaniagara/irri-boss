
import '../../domain/entities/power_entities.dart';
import '../../domain/repositories/power_repo.dart';
import '../datasources/power_datasource.dart';



class PowerGraphRepositoryImpl implements PowerGraphRepository {
  final PowerRemoteDataSource dataSource;

  PowerGraphRepositoryImpl({required this.dataSource});

  @override
  Future<PowerGraphEntity> getGraphData({
    required int userId,
    required int subuserId,
    required int controllerId,
    required String fromDate,
    required String toDate,
    required int sum,
  }) async {
    final model = await dataSource.PowergraphData(
      userId: userId,
      subuserId: subuserId,
      controllerId: controllerId,
      fromDate: fromDate,
      toDate: toDate,
      sum: sum,
    );

    return PowerGraphEntity(
      code: model.code,
      message: model.message,
      data: model.data.map(
            (d) => PowerDatumEntity(date: d.date ?? '' , time: d.time ?? '', totalPowerOnTime: d.totalPowerOnTime, totalPowerOffTime: d.totalPowerOffTime, motorRunTime: d.motorRunTime, motorRunTime2: d.motorRunTime2, motorIdleTime: d.motorIdleTime, motorIdleTime2: d.motorIdleTime2, dryRunTripTime: d.dryRunTripTime, dryRunTripTime2: d.dryRunTripTime2, cyclicTripTime: d.cyclicTripTime, cyclicTripTime2: d.cyclicTripTime2, otherTripTime: d.otherTripTime, otherTripTime2: d.otherTripTime2, totalFlowToday: d.totalFlowToday, cumulativeFlowToday: d.cumulativeFlowToday, averageFlowRate: d.averageFlowRate, pressureIn: d.pressureIn, pressureOut: d.pressureOut, battery1Volt: d.battery1Volt, battery2Volt: d.battery2Volt, battery3Volt: d.battery3Volt, battery4Volt: d.battery4Volt, solar1Volt: d.solar1Volt, solar2Volt: d.solar2Volt, solar3Volt: d.solar3Volt, solar4Volt: d.solar4Volt),
      ).toList(),
    );
  }
}
