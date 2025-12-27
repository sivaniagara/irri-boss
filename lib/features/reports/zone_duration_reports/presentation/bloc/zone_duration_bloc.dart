import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zone_duration_reports/presentation/bloc/zone_duration_bloc_event.dart';
import 'package:niagara_smart_drip_irrigation/features/reports/zone_duration_reports/presentation/bloc/zone_duration_bloc_state.dart';

import '../../domain/usecases/fetch_zone_duration_data.dart';



class ZoneDurationBloc
    extends Bloc<ZoneDurationEvent, ZoneDurationState> {
  final FetchZoneDurationData fetchZoneDurationData;

  ZoneDurationBloc({
    required this.fetchZoneDurationData,
  }) : super(ZoneDurationInitial()) {
    on<FetchZoneDurationEvent>(_onFetchZoneDuration);
  }

  Future<void> _onFetchZoneDuration(
      FetchZoneDurationEvent event,
      Emitter<ZoneDurationState> emit,
      ) async {
    emit(ZoneDurationLoading());

    try {
      final result = await fetchZoneDurationData(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      emit(
        ZoneDurationLoaded(
          data: result,
          fromDate: event.fromDate,
          toDate: event.toDate,
        ),
      );
    } catch (e) {
      emit(
        ZoneDurationError(
          e.toString().replaceAll('Exception:', ''),
        ),
      );
    }
  }
}
