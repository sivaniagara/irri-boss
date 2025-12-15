import 'package:flutter_bloc/flutter_bloc.dart';
import 'sendrev_bloc_event.dart';
import 'sendrev_bloc_state.dart';
import '../../domain/usecases/sendrev_params.dart';

class SendrevBloc extends Bloc<SendrevEvent, SendrevState> {
  final FetchSendRevMessages fetchSendRevMessages;

  SendrevBloc({required this.fetchSendRevMessages})
      : super(SendrevInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
  }


  Future<void> _onLoadMessages(
      LoadMessagesEvent event, Emitter<SendrevState> emit) async {
    emit(SendrevLoading());
    try {
      // Call the use case with parameters from the event
      final result = await fetchSendRevMessages.call(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      // result is SendrevEntity, now we can access .data
      emit(SendrevLoaded(result.data));
    } catch (e) {
      emit(SendrevError(e.toString()));
    }
  }

}
