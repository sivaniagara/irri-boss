import 'package:equatable/equatable.dart';
import 'report_menu_event.dart';

abstract class ReportMenuState extends Equatable {
  const ReportMenuState();

  @override
  List<Object?> get props => [];
}

class ReportMenuInitial extends ReportMenuState {}

class ReportMenuNavigate extends ReportMenuState {
  final ReportType reportType;

  const ReportMenuNavigate(this.reportType);

  @override
  List<Object?> get props => [reportType];
}
