import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/flow_graph_data.dart';
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

      emit(
        FlowGraphLoaded(
          data: result,
          fromDate: event.fromDate,
          toDate: event.toDate,
        ),
      );
    } catch (e) {
      emit(
        FlowGraphError(
          e.toString().replaceAll('Exception:', ''),
        ),
      );
    }
  }
}
