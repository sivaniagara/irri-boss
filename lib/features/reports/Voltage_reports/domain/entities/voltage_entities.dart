class VoltageGraphEntities {
  final int code;
  final String message;
  final List<VoltageDatumEntity> data;

  VoltageGraphEntities({
    required this.code,
    required this.message,
    required this.data,
  });
}

class VoltageDatumEntity {
  final String date;
  final String time;

  final String r;
  final String y;
  final String b;
  final String ry;
  final String yb;
  final String br;

  final String c1;
  final String c2;
  final String c3;

  final String runTime;
  final String runFlow;
  final String lastDayRunTime;
  final String lastDayrunFlow;

  final String twoPhaseOnTime;
  final String twoPhaseLastDayOnTime;
  final String threePhaseOnTime;
  final String threePhaseLastDayOnTime;

  final String powerOffTime;
  final String lastDayPowerOffTime;
  final String totalPowerOnTime;
  final String totalPowerOffTime;

  final String wellLevel;
  final String wellPercentage;
  final String csq;

  final String battery1Volt;
  final String battery2Volt;
  final String battery3Volt;
  final String battery4Volt;

  final String solar1Volt;
  final String solar2Volt;
  final String solar3Volt;
  final String solar4Volt;

  VoltageDatumEntity({
    required this.date,
    required this.time,
    required this.r,
    required this.y,
    required this.b,
    required this.ry,
    required this.yb,
    required this.br,
    required this.c1,
    required this.c2,
    required this.c3,
    required this.runTime,
    required this.runFlow,
    required this.lastDayRunTime,
    required this.lastDayrunFlow,
    required this.twoPhaseOnTime,
    required this.twoPhaseLastDayOnTime,
    required this.threePhaseOnTime,
    required this.threePhaseLastDayOnTime,
    required this.powerOffTime,
    required this.lastDayPowerOffTime,
    required this.totalPowerOnTime,
    required this.totalPowerOffTime,
    required this.wellLevel,
    required this.wellPercentage,
    required this.csq,
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
