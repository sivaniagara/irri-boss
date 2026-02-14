import 'package:flutter_bloc/flutter_bloc.dart';
import 'get_moisture_status_event.dart';
import 'get_moisture_status_state.dart';
import '../../domain/usecases/get_moisture_status.dart';

class GetMoistureStatusBloc extends Bloc<GetMoistureStatusEvent, GetMoistureStatusState> {
  final GetMoistureStatus getMoistureStatus;

  GetMoistureStatusBloc({required this.getMoistureStatus}) : super(GetMoistureStatusInitial()) {
    on<FetchGetMoistureStatus>((event, emit) async {
      emit(GetMoistureStatusLoading());
      final failureOrMoistureStatus = await getMoistureStatus(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );
      failureOrMoistureStatus.fold(
        (failure) => emit(GetMoistureStatusError(failure.message)),
        (moistureStatus) => emit(GetMoistureStatusLoaded(moistureStatus)),
      );
    });
  }
}
