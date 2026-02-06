import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'sendrev_bloc_event.dart';
import 'sendrev_bloc_state.dart';
import '../../domain/usecases/sendrev_params.dart';

class SendrevBloc extends Bloc<SendrevEvent, SendrevState> {
  final FetchSendRevMessages fetchSendRevMessages;
  Timer? _pollingTimer;

  SendrevBloc({required this.fetchSendRevMessages})
      : super(SendrevInitial()) {
    on<LoadMessagesEvent>(_onLoadMessages);
    on<StartPollingEvent>(_onStartPolling);
    on<StopPollingEvent>(_onStopPolling);
  }

  Future<void> _onLoadMessages(
      LoadMessagesEvent event, Emitter<SendrevState> emit) async {
    // Only show loading if we don't have messages yet
    if (state is! SendrevLoaded) {
      emit(SendrevLoading());
    }
    
    try {
      final result = await fetchSendRevMessages.call(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      );

      emit(SendrevLoaded(result.data));
    } catch (e) {
      // If we already have data, don't emit error state, maybe just log it
      if (state is! SendrevLoaded) {
        emit(SendrevError(e.toString()));
      }
    }
  }

  void _onStartPolling(StartPollingEvent event, Emitter<SendrevState> emit) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      add(LoadMessagesEvent(
        userId: event.userId,
        subuserId: event.subuserId,
        controllerId: event.controllerId,
        fromDate: event.fromDate,
        toDate: event.toDate,
      ));
    });
  }

  void _onStopPolling(StopPollingEvent event, Emitter<SendrevState> emit) {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
