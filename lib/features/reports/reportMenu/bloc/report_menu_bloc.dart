import 'package:flutter_bloc/flutter_bloc.dart';
import 'report_menu_event.dart';
import 'report_menu_state.dart';

class ReportMenuBloc extends Bloc<ReportMenuEvent, ReportMenuState> {
  ReportMenuBloc() : super(ReportMenuInitial()) {
    on<ReportMenuClicked>(_onReportClicked);
  }

  void _onReportClicked(
      ReportMenuClicked event,
      Emitter<ReportMenuState> emit,
      ) {
    emit(ReportMenuNavigate(event.reportType));
  }
}
