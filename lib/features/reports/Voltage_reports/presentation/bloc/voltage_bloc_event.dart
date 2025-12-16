abstract class VoltageGraphEvent {}


class LoadVoltageGraphEvent extends VoltageGraphEvent {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  LoadVoltageGraphEvent({
    required this.userId,
    required this.subuserId,
    required this.controllerId,
    required this.fromDate,
    required this.toDate,
  });
}
