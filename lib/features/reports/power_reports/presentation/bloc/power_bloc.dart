import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/power_reports/presentation/bloc/power_bloc_event.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/power_reports/presentation/bloc/power_bloc_state.dart';

import '../../domain/usecases/fetchpowergraphdata.dart';

class PowerGraphBloc
    extends Bloc<PowerGraphEvent, PowerGraphState> {
  final FetchPowerGraphData fetchPowerGraphData;

  PowerGraphBloc({
    required this.fetchPowerGraphData,
  }) : super(PowerGraphInitial()) {
    on<FetchPowerGraphEvent>(_onFetchPowerGraph);
  }

  Future<void> _onFetchPowerGraph(
      FetchPowerGraphEvent event,
      Emitter<PowerGraphState> emit,
      ) async {
    emit(PowerGraphLoading());

    try {
      final result = await fetchPowerGraphData(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        toDate: event.toDate,
        sum: event.sum,
       );

      emit(PowerGraphLoaded(data: result, fromDate: event.fromDate, toDate: event.toDate));
    } catch (e) {
      emit(
        PowerGraphError(
          e.toString().replaceAll('Exception:', ''),
        ),
      );
    }
  }
}
