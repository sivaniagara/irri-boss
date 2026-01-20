// ---------------------- Zone Duration Entity ----------------------

class ZoneDurationEntity {
  final int code;
  final String message;
  final List<ZoneDurationDatumEntity> data;

  final String totDuration;
  final String totFlow;
  final String powerDuration;
  final String ctrlDuration;
  final String ctrlDuration1;

  ZoneDurationEntity({
    required this.code,
    required this.message,
    required this.data,
    required this.totDuration,
    required this.totFlow,
    required this.powerDuration,
    required this.ctrlDuration,
    required this.ctrlDuration1,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'totDuration': totDuration,
      'totFlow': totFlow,
      'powerDuration': powerDuration,
      'ctrlDuration': ctrlDuration,
      'ctrlDuration1': ctrlDuration1,
    };
  }
}

// ---------------------- Zone Duration Datum Entity ----------------------

class ZoneDurationDatumEntity {
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

  final String ec;
  final String ph;

  final String program;

  final String vrb;
  final String c1;
  final String c2;
  final String c3;

  ZoneDurationDatumEntity({
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
    required this.ec,
    required this.ph,
    required this.program,
    required this.vrb,
    required this.c1,
    required this.c2,
    required this.c3,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'zone': zone,
      'onTime': onTime,
      'offDate': offDate,
      'offTime': offTime,
      'duration': duration,
      'dateTime': dateTime,
      'flow': flow,
      'pressure': pressure,
      'pressureIn': pressureIn,
      'pressureOut': pressureOut,
      'wellLevel': wellLevel,
      'wellPercentage': wellPercentage,
      'ec': ec,
      'ph': ph,
      'program': program,
      'vrb': vrb,
      'c1': c1,
      'c2': c2,
      'c3': c3,
    };
  }
}
