// ---------------------- Power Graph Entities ----------------------
class PowerGraphEntity {
  final int code;
  final String message;
  final List<PowerDatumEntity> data;

  PowerGraphEntity({
    required this.code,
    required this.message,
    required this.data,
  });
}



class PowerDatumEntity {
  final String date;
  final String time;

  final String totalPowerOnTime;
  final String totalPowerOffTime;
  final String motorRunTime;
  final String motorRunTime2;
  final String motorIdleTime;
  final String motorIdleTime2;
  final String dryRunTripTime;
  final String dryRunTripTime2;
  final String cyclicTripTime;
  final String cyclicTripTime2;
  final String otherTripTime;
  final String otherTripTime2;

  final String totalFlowToday;
  final String cumulativeFlowToday;
  final String averageFlowRate;
  final String pressureIn;
  final String pressureOut;

  final String battery1Volt;
  final String battery2Volt;
  final String battery3Volt;
  final String battery4Volt;
  final String solar1Volt;
  final String solar2Volt;
  final String solar3Volt;
  final String solar4Volt;

  PowerDatumEntity({
    required this.date,
    required this.time,
    required this.totalPowerOnTime,
    required this.totalPowerOffTime,
    required this.motorRunTime,
    required this.motorRunTime2,
    required this.motorIdleTime,
    required this.motorIdleTime2,
    required this.dryRunTripTime,
    required this.dryRunTripTime2,
    required this.cyclicTripTime,
    required this.cyclicTripTime2,
    required this.otherTripTime,
    required this.otherTripTime2,
    required this.totalFlowToday,
    required this.cumulativeFlowToday,
    required this.averageFlowRate,
    required this.pressureIn,
    required this.pressureOut,
    required this.battery1Volt,
    required this.battery2Volt,
    required this.battery3Volt,
    required this.battery4Volt,
    required this.solar1Volt,
    required this.solar2Volt,
    required this.solar3Volt,
    required this.solar4Volt,
  });

}
