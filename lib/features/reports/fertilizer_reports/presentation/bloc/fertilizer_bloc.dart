import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/fetch_fertilizer_data.dart';
import 'fertilizer_bloc_event.dart';
import 'fertilizer_bloc_state.dart';



class FertilizerBloc
    extends Bloc<FertilizerEvent, FertilizerState> {
  final FetchFertilizerData fetchFertilizerData;

  FertilizerBloc({
    required this.fetchFertilizerData,
  }) : super(FertilizerInitial()) {
    on<FetchFertilizerEvent>(_onFetchFertilizer);
  }

  Future<void> _onFetchFertilizer(
      FetchFertilizerEvent event,
      Emitter<FertilizerState> emit,
      ) async {
    emit(FertilizerLoading());

    try {
      final result = await fetchFertilizerData(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      emit(
        FertilizerLoaded(
          data: result,
          fromDate: event.fromDate,
          toDate: event.toDate,
        ),
      );
    } catch (e) {
      emit(
        FertilizerError(
          e.toString().replaceAll('Exception:', ''),
        ),
      );
    }
  }
}
