import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/standalone_reports/presentation/bloc/standalone_bloc_event.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/standalone_reports/presentation/bloc/standalone_bloc_state.dart';

import '../../domain/usecases/standalone_data.dart';

 

class StandaloneBloc
    extends Bloc<StandaloneEvent, StandaloneState> {
  final FetchStandaloneData fetchStandaloneData;

  StandaloneBloc({
    required this.fetchStandaloneData,
  }) : super(StandaloneInitial()) {
    on<FetchStandaloneEvent>(_onFetchStandalone);
  }

  Future<void> _onFetchStandalone(
      FetchStandaloneEvent event,
      Emitter<StandaloneState> emit,
      ) async {
    emit(StandaloneLoading());

    try {
      final result = await fetchStandaloneData(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      emit(
        StandaloneLoaded(
          data: result,
          fromDate: event.fromDate,
          toDate: event.toDate,
        ),
      );
    } catch (e) {
      emit(
        StandaloneError(
          e.toString().replaceAll('Exception:', ''),
        ),
      );
    }
  }
}
