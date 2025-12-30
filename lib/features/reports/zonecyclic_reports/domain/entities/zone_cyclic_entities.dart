class ZoneCyclicEntity {
  final int code;
  final String message;
  final List<ZoneProgramEntity> data;
  final String totalDuration;
  final String totalFlow;
  final String powerDuration;
  final String controllerDuration;
  final String controllerDuration1;

  const ZoneCyclicEntity({
    required this.code,
    required this.message,
    required this.data,
    required this.totalDuration,
    required this.totalFlow,
    required this.powerDuration,
    required this.controllerDuration,
    required this.controllerDuration1,
  });
}
class ZoneProgramEntity {
  final String program;
  final List<ZoneCyclicDetailEntity> zoneList;

  const ZoneProgramEntity({
    required this.program,
    required this.zoneList,
  });
}
class ZoneCyclicDetailEntity {
  final String date;
  final String zone;
  final String onTime;
  final String offDate;
  final String offTime;
  final String duration;
  final String dateTime;
  final String flow;
  final String pressure;
  final String pressureIn;
  final String pressureOut;
  final String wellLevel;
  final String wellPercentage;
  final String ph;

  const ZoneCyclicDetailEntity({
    required this.date,
    required this.zone,
    required this.onTime,
    required this.offDate,
    required this.offTime,
    required this.duration,
    required this.dateTime,
    required this.flow,
    required this.pressure,
    required this.pressureIn,
    required this.pressureOut,
    required this.wellLevel,
    required this.wellPercentage,
    required this.ph,
  });
}
