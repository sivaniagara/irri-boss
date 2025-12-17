import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/bloc/voltage_bloc_event.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/bloc/voltage_bloc_state.dart';

import '../../domain/usecases/fetchvoltagegraphdata.dart';


class VoltageGraphBloc
    extends Bloc<VoltageGraphEvent, VoltageGraphState> {
  final FetchVoltageGraphData fetchVoltageGraphData;

  VoltageGraphBloc({
    required this.fetchVoltageGraphData,
  }) : super(VoltageGraphInitial()) {
    on<FetchVoltageGraphEvent>(_onFetchVoltageGraph);
  }

  Future<void> _onFetchVoltageGraph(
      FetchVoltageGraphEvent event,
      Emitter<VoltageGraphState> emit,
      ) async {
    emit(VoltageGraphLoading());

    try {
      final result = await fetchVoltageGraphData(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      emit(VoltageGraphLoaded(result));
    } catch (e) {
      emit(
        VoltageGraphError(
          e.toString().replaceAll('Exception:', ''),
        ),
      );
    }
  }
}
