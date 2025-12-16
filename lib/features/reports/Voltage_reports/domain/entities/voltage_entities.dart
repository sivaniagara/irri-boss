

class VoltageGraphEntities {
  int code;
  String message;
  List<VoltageDatum> data;

  VoltageGraphEntities({
    required this.code,
    required this.message,
    required this.data,
  });

}

class VoltageDatum {
  String date;
  String time;
  String r;
  String y;
  String b;
  String ry;
  String yb;
  String br;
  String c1;
  String c2;
  String c3;
  String runTime;
  String runFlow;
  String lastDayRunTime;
  String lastDayrunFlow;
  String twoPhaseOnTime;
  String twoPhaseLastDayOnTime;
  String threePhaseOnTime;
  String threePhaseLastDayOnTime;
  String powerOffTime;
  String lastDayPowerOffTime;
  String totalPowerOnTime;
  String totalPowerOffTime;
  String wellLevel;
  String wellPercentage;
  String csq;
  String battery1Volt;
  String battery2Volt;
  String battery3Volt;
  String battery4Volt;
  String solar1Volt;
  String solar2Volt;
  String solar3Volt;
  String solar4Volt;

  VoltageDatum({
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

