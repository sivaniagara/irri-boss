import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../mapping_and_unmapping_nodes/domain/usecases/fetch_mapping_unmapping_nodes_usecase.dart';
import 'report_menu_event.dart';
import 'report_menu_state.dart';

class ReportMenuBloc extends Bloc<ReportMenuEvent, ReportMenuState> {
  final FetchMappingUnmappingNodesUsecase fetchMappingUnmappingNodesUsecase;

  ReportMenuBloc({required this.fetchMappingUnmappingNodesUsecase}) : super(ReportMenuInitial()) {
    on<ReportMenuClicked>(_onReportClicked);
    on<FetchReportMenuData>(_onFetchReportMenuData);
  }

  void _onReportClicked(
      ReportMenuClicked event,
      Emitter<ReportMenuState> emit,
      ) {
    emit(ReportMenuNavigate(event.reportType));
  }

  Future<void> _onFetchReportMenuData(
      FetchReportMenuData event,
      Emitter<ReportMenuState> emit,
      ) async {
    emit(ReportMenuLoading());
    final result = await fetchMappingUnmappingNodesUsecase(FetchMappingUnmappingParams(
      userId: event.userId,
      controllerId: event.controllerId,
    ));

    result.fold(
      (failure) => emit(ReportMenuError(failure.message)),
      (data) => emit(ReportMenuLoaded(mappedNodes: data.listOfMappedNodeEntity)),
    );
  }
}
