import 'package:equatable/equatable.dart';

enum ReportType {
  voltage,
  powerGraph,
  motorCyclic,
  zoneDuration,
  standalone,
  todayZone,
  zoneCyclic,
  flowGraph,
  fertilizer,
  moisture,
  fertilizerLive,
  greenHouse,
}

abstract class ReportMenuEvent extends Equatable {
  const ReportMenuEvent();

  @override
  List<Object?> get props => [];
}

class ReportMenuClicked extends ReportMenuEvent {
  final ReportType reportType;

  const ReportMenuClicked(this.reportType);

  @override
  List<Object?> get props => [reportType];
}

class FetchReportMenuData extends ReportMenuEvent {
  final String userId;
  final String controllerId;

  const FetchReportMenuData({required this.userId, required this.controllerId});

  @override
  List<Object?> get props => [userId, controllerId];
}
