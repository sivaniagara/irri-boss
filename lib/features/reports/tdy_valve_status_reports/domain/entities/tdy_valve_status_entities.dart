class TdyValveStatusEntity {
  final int code;
  final String message;
  final int totalFlow;
  final List<TdyValveStatusDatumEntity> data;

  const TdyValveStatusEntity({
    required this.code,
    required this.message,
    required this.totalFlow,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'totalFlow': totalFlow,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }
}

class TdyValveStatusDatumEntity {
  final String zone;
  final String duration;
  final String litres;
  final String zonePlace;
  final int? totalFlow;

  const TdyValveStatusDatumEntity({
    required this.zone,
    required this.duration,
    required this.litres,
    required this.zonePlace,
    this.totalFlow,
  });

  Map<String, dynamic> toJson() {
    return {
      'zone': zone,
      'duration': duration,
      'litres': litres,
      'zonePlace': zonePlace,
      if (totalFlow != null) 'totalFlow': totalFlow,
    };
  }
}
