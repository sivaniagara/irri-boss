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
