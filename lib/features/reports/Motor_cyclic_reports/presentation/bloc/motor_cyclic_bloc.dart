import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/fetch_motor_cyclic_data.dart';
import 'motor_cyclic_bloc_event.dart';
import 'motor_cyclic_bloc_state.dart';

class MotorCyclicBloc
    extends Bloc<MotorCyclicEvent, MotorCyclicState> {
  final FetchMotorCyclicData fetchMotorCyclicData;

  MotorCyclicBloc({
    required this.fetchMotorCyclicData,
  }) : super(MotorCyclicInitial()) {
    on<FetchMotorCyclicEvent>(_onFetchMotorCyclic);
  }

  Future<void> _onFetchMotorCyclic(
      FetchMotorCyclicEvent event,
      Emitter<MotorCyclicState> emit,
      ) async {
    emit(MotorCyclicLoading());

    try {
      final result = await fetchMotorCyclicData(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      emit(
        MotorCyclicLoaded(
          data: result,
          fromDate: event.fromDate,
          toDate: event.toDate,
        ),
      );
    } catch (e) {
      emit(
        MotorCyclicError(
          e.toString().replaceAll('Exception:', ''),
        ),
      );
    }
  }
}
