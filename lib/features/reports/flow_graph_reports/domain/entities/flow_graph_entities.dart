class FlowGraphEntities {
  final int code;
  final String message;
  final List<FlowGraphDataEntity> data;

  FlowGraphEntities({
    required this.code,
    required this.message,
    required this.data,
  });
}

class FlowGraphDataEntity {
  final String date;
  final String totalFlow;
  final String totalRunTime;
  final String total3PhaseOnTime;
  final String total2PhaseOnTime;
  final String totalPowerOnTime;

  FlowGraphDataEntity({
    required this.date,
    required this.totalFlow,
    required this.totalRunTime,
    required this.total3PhaseOnTime,
    required this.total2PhaseOnTime,
    required this.totalPowerOnTime,
  });
}
