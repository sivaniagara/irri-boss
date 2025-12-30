// ---------------------- Moto Cyclic Entities ----------------------

class MotoCyclicEntity {
  final int code;
  final String message;
  final List<MotoCyclicDatumEntity> data;

  final String totDuration;
  final String totFlow;
  final String powerDuration;
  final String ctrlDuration;
  final String ctrlDuration1;

  MotoCyclicEntity({
    required this.code,
    required this.message,
    required this.data,
    required this.totDuration,
    required this.totFlow,
    required this.powerDuration,
    required this.ctrlDuration,
    required this.ctrlDuration1,
  });
}

// ---------------------- Moto Cyclic Datum Entity ----------------------

class MotoCyclicDatumEntity {
  final String program;
  final String ctrlMsg;
  final List<MotoCyclicZoneEntity> zoneList;

  MotoCyclicDatumEntity({
    required this.program,
    required this.ctrlMsg,
    required this.zoneList,
  });
}

// ---------------------- Moto Cyclic Zone Entity ----------------------

class MotoCyclicZoneEntity {
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
  final String ec;

  final String vrb;
  final String c1;
  final String c2;
  final String c3;

  MotoCyclicZoneEntity({
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
    required this.ec,
    required this.vrb,
    required this.c1,
    required this.c2,
    required this.c3,
  });
}
