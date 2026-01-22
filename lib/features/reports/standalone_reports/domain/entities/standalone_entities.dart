class StandaloneEntity {
  final int code;
  final String message;
  final List<StandaloneDatumEntity> data;
  final String totalDuration;
  final String totalFlow;
  final String powerDuration;
  final String controllerDuration;
  final String controllerDuration1;

  const StandaloneEntity({
    required this.code,
    required this.message,
    required this.data,
    required this.totalDuration,
    required this.totalFlow,
    required this.powerDuration,
    required this.controllerDuration,
    required this.controllerDuration1,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
      'totalDuration': totalDuration,
      'totalFlow': totalFlow,
      'powerDuration': powerDuration,
      'controllerDuration': controllerDuration,
      'controllerDuration1': controllerDuration1,
    };
  }
}

class StandaloneDatumEntity {
  final String date;
  final String zone;
  final String onTime;
  final String offDate;
  final String offTime;
  final String duration;
  final String dateTime;

  const StandaloneDatumEntity({
    required this.date,
    required this.zone,
    required this.onTime,
    required this.offDate,
    required this.offTime,
    required this.duration,
    required this.dateTime,
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
    };
  }
}
