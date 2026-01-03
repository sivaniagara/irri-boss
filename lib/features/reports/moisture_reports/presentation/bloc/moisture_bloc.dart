import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/moisture_data.dart';
import 'moisture_bloc_event.dart';
import 'moisture_bloc_state.dart';


class MoistureBloc extends Bloc<MoistureEvent, MoistureState> {
  final FetchMoistureData fetchMoistureData;

  MoistureBloc({
    required this.fetchMoistureData,
  }) : super(MoistureInitial()) {
    on<FetchMoistureEvent>(_onFetchMoisture);
  }

  Future<void> _onFetchMoisture(
      FetchMoistureEvent event,
      Emitter<MoistureState> emit,
      ) async {
    emit(MoistureLoading());

    try {
      final result = await fetchMoistureData(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
      );

      emit(MoistureLoaded(data: result));
    } catch (e) {
      emit(
        MoistureError(
          e.toString().replaceFirst('Exception:', '').trim(),
        ),
      );
    }
  }
}