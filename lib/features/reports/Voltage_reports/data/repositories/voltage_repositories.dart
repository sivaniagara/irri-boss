//
//
//
// import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/domain/repositories/voltage_repo.dart';
//
// import '../../domain/entities/voltage_entities.dart';
// import '../datasources/voltage_datasource.dart';
//
// class VoltageGraphRepositoryImpl implements VoltageGraphRepository {
//   final VoltageRemoteDataSource dataSource;
//
//   VoltageGraphRepositoryImpl({required this.dataSource});
//
//    Future<VoltageGraphEntities> getGraphData({
//     required int userId,
//     required int subuserId,
//     required int controllerId,
//     required String fromDate,
//     required String toDate,
//   }) async {
//     // Call remote data source
//     final model = await dataSource.VoltagegraphData(
//       userId: userId,
//       subuserId: subuserId,
//       controllerId: controllerId,
//       fromDate: fromDate,
//       toDate: toDate,
//     );
//
//     // Map model to entity
//     return VoltageGraphEntities(
//       code: model.code,
//       message: model.message,
//       data: model.data
//           .map(
//             (d) => VoltageDatum(date: d.date, time: d.time, r: d.r, y: d.y, b: d.b, ry: d.ry, yb: d.yb, br: d.br, c1: d.c1, c2: d.c2, c3: d.c3, runTime: d.runTime, runFlow: d.runFlow, lastDayRunTime: d.lastDayRunTime, lastDayrunFlow: d.lastDayrunFlow, twoPhaseOnTime: d.twoPhaseOnTime, twoPhaseLastDayOnTime: d.twoPhaseLastDayOnTime, threePhaseOnTime: d.threePhaseOnTime, threePhaseLastDayOnTime: d.threePhaseLastDayOnTime, powerOffTime: d.powerOffTime, lastDayPowerOffTime: d.lastDayPowerOffTime, totalPowerOnTime: d.totalPowerOnTime, totalPowerOffTime: d.totalPowerOffTime, wellLevel: d.wellLevel, wellPercentage: d.wellPercentage, csq: d.csq, battery1Volt: d.battery1Volt, battery2Volt: d.battery2Volt, battery3Volt: d.battery3Volt, battery4Volt: d.battery4Volt, solar1Volt: d.solar1Volt, solar2Volt: d.solar2Volt, solar3Volt: d.solar3Volt, solar4Volt: d.solar4Volt),
//       )
//           .toList(),
//     );
//   }
// }