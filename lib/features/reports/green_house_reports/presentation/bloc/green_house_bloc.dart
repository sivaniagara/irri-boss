// greenhouse_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

import 'green_house_bloc_event.dart';
import 'green_house_bloc_state.dart';

// greenhouse_bloc.dart
class GreenHouseBloc extends Bloc<GreenHouseEvent, GreenHouseState> {
  GreenHouseBloc() : super(GreenHouseInitial()) {
    on<FetchGreenHouseReportEvent>(_onFetch);
  }

  void _onFetch(
      FetchGreenHouseReportEvent event,
      Emitter<GreenHouseState> emit,
      ) {
    emit(GreenHouseLoading());

    try {
      final url =
          'http://3.1.62.165:8086/report'
          '/${event.userId}'
          '/${event.subuserId}'
          '/${event.controllerId}'
          '/${event.fromDate}'
          '/${event.toDate}'
          '/greenhouseruntime';

      emit(GreenHouseLoaded(url));
    } catch (_) {
      emit(GreenHouseError('Failed to load Green House Report'));
    }
  }
}

