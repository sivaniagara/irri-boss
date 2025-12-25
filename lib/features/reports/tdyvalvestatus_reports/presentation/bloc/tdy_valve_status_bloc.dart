import 'package:flutter_bloc/flutter_bloc.dart';
 import 'package:niagara_smart_drip_irrigation/features/reports/tdyvalvestatus_reports/presentation/bloc/tdy_valve_status_bloc_event.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/tdyvalvestatus_reports/presentation/bloc/tdy_valve_status_bloc_state.dart';

import '../../domain/usecases/tdy_valve_status_data.dart';


class TdyValveStatusBloc
    extends Bloc<TdyValveStatusEvent, TdyValveStatusState> {
  final FetchTdyValveStatusData fetchTdyValveStatusData;

  TdyValveStatusBloc({
    required this.fetchTdyValveStatusData,
  }) : super(TdyValveStatusInitial()) {
    on<FetchTdyValveStatusEvent>(_onFetchTdyValveStatus);
  }

  Future<void> _onFetchTdyValveStatus(
      FetchTdyValveStatusEvent event,
      Emitter<TdyValveStatusState> emit,
      ) async {
    emit(TdyValveStatusLoading());

    try {
      final result = await fetchTdyValveStatusData(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        program: event.program,
      );

      emit(
        TdyValveStatusLoaded(
          data: result,
          fromDate: event.fromDate,
          program: event.program,
        ),
      );
    } catch (e) {
      emit(
        TdyValveStatusError(
          e.toString().replaceAll('Exception:', ''),
        ),
      );
    }
  }
}
