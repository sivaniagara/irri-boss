import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/bloc/voltage_bloc_event.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/Voltage_reports/presentation/bloc/voltage_bloc_state.dart';

import '../../domain/usecases/fetchFlowGraphdata.dart';
import '../../domain/usecases/fetchflowgraphdata.dart' hide FetchFlowGraphData;
import 'flow_graph_bloc_event.dart';
import 'flow_graph_bloc_state.dart';


class FlowGraphBloc
    extends Bloc<FlowGraphEvent, FlowGraphState> {
  final FetchFlowGraphData fetchFlowGraphData;

  FlowGraphBloc({
    required this.fetchFlowGraphData,
  }) : super(FlowGraphInitial()) {
    on<FetchFlowGraphEvent>(_onFetchFlowGraph);
  }

  Future<void> _onFetchFlowGraph(
      FetchFlowGraphEvent event,
      Emitter<FlowGraphState> emit,
      ) async {
    emit(FlowGraphLoading());

    try {
      final result = await fetchFlowGraphData(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      emit(FlowGraphLoaded(result));
    } catch (e) {
      emit(
        FlowGraphError(
          e.toString().replaceAll('Exception:', ''),
        ),
      );
    }
  }
}
