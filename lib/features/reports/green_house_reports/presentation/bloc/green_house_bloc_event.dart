// greenhouse_event.dart
abstract class GreenHouseEvent {}

class FetchGreenHouseReportEvent extends GreenHouseEvent {
  final int userId;
  final int subuserId;
  final int controllerId;
  final String fromDate;
  final String toDate;

  FetchGreenHouseReportEvent({
    required this.userId,
    required this.subuserId,
    required this.controllerId,
    required this.fromDate,
    required this.toDate,
  });
}
