import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/presentation/bloc/zone_cyclic_bloc_event.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zonecyclic_reports/presentation/bloc/zone_cyclic_bloc_state.dart';

import '../../domain/usecases/zone_cyclic_data.dart';



class ZoneCyclicBloc
    extends Bloc<ZoneCyclicEvent, ZoneCyclicState> {
  final FetchZoneCyclicData fetchZoneCyclicData;

  ZoneCyclicBloc({
    required this.fetchZoneCyclicData,
  }) : super(ZoneCyclicInitial()) {
    on<FetchZoneCyclicEvent>(_onFetchZoneCyclic);
  }

  Future<void> _onFetchZoneCyclic(
      FetchZoneCyclicEvent event,
      Emitter<ZoneCyclicState> emit,
      ) async {
    emit(ZoneCyclicLoading());

    try {
      final result = await fetchZoneCyclicData(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      emit(
        ZoneCyclicLoaded(
          data: result,
          fromDate: event.fromDate,
          toDate: event.toDate,
        ),
      );
    } catch (e) {
      emit(
        ZoneCyclicError(
          e.toString().replaceAll('Exception:', ''),
        ),
      );
    }
  }
}
