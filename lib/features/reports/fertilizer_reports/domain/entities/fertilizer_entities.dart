// ---------------------- Fertilizer Entity ----------------------
class FertilizerEntity {
  final int code;
  final String message;
  final List<FertilizerDatumEntity> data;
  final String totDuration;
  final String totFlow;
  final String powerDuration;
  final String ctrlDuration;
  final String ctrlDuration1;

  FertilizerEntity({
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

// ---------------------- Fertilizer Datum Entity ----------------------
class FertilizerDatumEntity {
  final String date;
  final String fertPump;
  final String onTime;
  final String offDate;
  final String offTime;
  final String duration;
  final String flow;
  final String zoneNumber;

  FertilizerDatumEntity({
    required this.date,
    required this.fertPump,
    required this.onTime,
    required this.offDate,
    required this.offTime,
    required this.duration,
    required this.flow,
    required this.zoneNumber,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'fertPump': fertPump,
      'onTime': onTime,
      'offDate': offDate,
      'offTime': offTime,
      'duration': duration,
      'flow': flow,
      'zoneNumber': zoneNumber,
    };
  }
}
